require_relative 'uspec_helper'

spec 'shows usage' do
  output = capture do
    exec 'bin/uspec -h'
  end

  output.include? 'usage'
end

spec 'pending test doesn\'t crash'

spec 'runs a path of specs' do
  output = capture do
    path = Pathname.new(__FILE__).parent.parent.join('example_specs').to_s
    Uspec::CLI.new(Array(path)).run_specs
  end

  output.include?('I love passing tests') || output
end

spec 'runs an individual spec' do
  output = capture do
    path =  Pathname.new(__FILE__).parent.parent.join('example_specs', 'example_spec.rb').to_s
    Uspec::CLI.new(Array(path)).run_specs
  end

  output.include?('I love passing tests') || output
end

spec 'broken requires in test files count as test failures' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'broken_require_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  $?.exitstatus == 1 || $?
end

spec 'displays information about test file with broken require' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'broken_require_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('cannot load such file') || output
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
