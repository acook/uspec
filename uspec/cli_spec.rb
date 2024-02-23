require_relative 'uspec_helper'

spec 'shows usage' do
  output = capture do
    exec 'bin/uspec -h'
  end

  output.include? 'usage'
end


def root
  Pathname.new(__FILE__).parent.parent
end

def examples
  root.join('example_specs')
end

def specs
  root.join('uspec')
end

def tests
  specs.join('test_specs')
end

def run_specs path
  Uspec::CLI.new(Array(path)).run_specs
end

spec 'runs a path of specs' do
  output = capture do
    run_specs examples.to_s
  end

  output.include?('I love passing tests') || output
end

spec 'runs an individual spec' do
  output = capture do
    run_specs examples.join('example_spec.rb').to_s
  end

  output.include?('I love passing tests') || output
end

spec 'broken requires in test files count as test failures' do
  output, status = Open3.capture2e "bin/uspec #{tests.join('broken_require_spec')}"

  status.exitstatus == 1 || status
end

spec 'displays information about test file with broken require' do
  output, status = Open3.capture2e "bin/uspec #{tests.join('broken_require_spec')}"

  output.include?('cannot load such file') || output
end

spec 'exit code is the number of failures' do
  expected = 50
  output = capture do
    @__uspec_harness.stats.clear_results! # because we're forking, we will have a copy of the current results

    expected.times do |count|
      spec "fail ##{count + 1}" do
        false
      end
    end

    exit @__uspec_harness.cli.exit_code
  end
  actual = $?.exitstatus

  actual == expected || output
end

spec 'when more than 255 failures, exit status is 255' do
  output = capture do
    @__uspec_harness.stats.clear_results! # because we're forking, we will have a copy of the current results

    500.times do
      spec 'fail' do
        false
      end
    end

    exit @__uspec_harness.cli.exit_code
  end

  $?.exitstatus == 255 || [$?, output]
end
