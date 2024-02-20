require_relative 'uspec_helper'

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
