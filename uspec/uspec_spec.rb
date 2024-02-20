require_relative 'uspec_helper'

spec 'catches errors' do
  output = capture do
    spec 'exception' do
      raise 'test exception'
    end
  end

  output.include?('Exception') || output
end

spec 'catches even non-StandardError-subclass exceptions' do
  output = capture do
    spec 'not implemented error' do
      raise ::NotImplementedError, 'test exception'
    end
  end

  output.include?('Exception') || output
end

spec 'complains when spec block returns non boolean' do
  output = capture do
    spec 'whatever' do
      "string"
    end
  end

  output.include?('Failed') || output
end

spec 'marks test as pending when no block supplied' do
  output = capture do
    spec 'pending test'
  end

  output.include?('pending') || output
end

spec 'should not define DSL methods on arbitrary objects' do
  !(Array.respond_to? :spec)
end

spec 'exit code is the number of failures' do
  expected = 50
  output = capture do
    @__uspec_dsl.__uspec_stats.clear_results! # because we're forking, we will have a copy of the current results

    expected.times do |count|
      spec "fail ##{count + 1}" do
        false
      end
    end

    exit @__uspec_dsl.__uspec_cli.exit_code
  end
  actual = $?.exitstatus

  actual == expected || output
end

spec 'when more than 255 failures, exit status is 255' do
  output = capture do
    @__uspec_dsl.__uspec_stats.clear_results! # because we're forking, we will have a copy of the current results

    500.times do
      spec 'fail' do
        false
      end
    end

    exit @__uspec_dsl.__uspec_cli.exit_code
  end

  $?.exitstatus == 255 || [$?, output]
end

spec 'extending with Uspec when already in a DSL does nothing' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'extend_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('[]') && output.include?('1 failed') || output
end

spec 'extending with Uspec in an arbitrary object makes the DSL available to it' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'extend_spec')

  output = capture do
    exec "ruby #{path}"
  end

  output.include?('[:spec]') && output.include?('1 failed') || output
end
