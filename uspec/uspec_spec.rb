require_relative 'uspec_helper'

spec 'catches errors' do
  output = capture do
    spec 'exception' do
      raise 'test exception'
    end
  end

  output.include? 'Exception'
end

spec 'catches even non-StandardError-subclass exceptions' do
  output = capture do
    spec 'not implemented error' do
      raise ::NotImplementedError, 'test exception'
    end
  end

  output.include? 'Exception'
end

spec 'complains when spec block returns non boolean' do
  output = capture do
    spec 'whatever' do
      "string"
    end
  end

  output.include? 'Unknown Result'
end

spec 'marks test as pending when no block supplied' do
  output = capture do
    spec 'pending test'
  end

  output.include? 'pending'
end

spec 'should not define DSL methods on arbitrary objects' do
  !(Array.respond_to? :spec)
end

spec 'exit code is the number of failures' do
  expected = 50
  output = capture do
    Uspec::Stats.clear_results! # because we're forking, we will have a copy of the current results

    expected.times do |count|
      spec "fail ##{count + 1}" do
        false
      end
    end

    puts(Uspec::Stats.inspect) unless Uspec::Stats.exit_code == expected
  end
  actual = $?.exitstatus

  actual == expected || puts("", output) || $?
end

spec 'if more than 255 failures, exit status is 255' do
  capture do
    Uspec::Stats.clear_results! # because we're forking, we will have a copy of the current results

    500.times do
      spec 'fail' do
        false
      end
    end
  end

  $?.exitstatus == 255 || $?
end
