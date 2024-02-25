require_relative 'uspec_helper'

def new_cli path  = '.'
  Uspec::CLI.new(Array(path))
end

def run_specs path
  new_cli(path).run_specs
end


spec 'shows usage' do
  output = capture do
    exec 'bin/uspec -h'
  end

  output.include? 'usage'
end

spec 'runs a path of specs' do
  output = outstr do
    run_specs exdir.to_s
  end

  output.include?('I love passing tests') || output
end

spec 'runs an individual file' do
  output = outstr do
    run_specs exdir.join('example_spec.rb').to_s
  end

  output.include?('I love passing tests') || output
end

spec 'runs an individual spec' do
  output = outstr do
    run_specs exdir.join('example_spec.rb:13').to_s
  end

  !output.include?('I love passing tests') && output.include?('non-boolean') || output
end

spec 'broken requires in test files count as test failures' do
  output, status = Open3.capture2e "#{root}/bin/uspec #{testdir.join('broken_require_spec')}"

  status.exitstatus == 1 || status
end

spec 'displays information about test file with broken require' do
  output, status = Open3.capture2e "#{root}/bin/uspec #{testdir.join('broken_require_spec')}"

  output.include?('cannot load such file') || output
end

spec 'exit code is the number of failures' do
  expected = 50
  cli = new_cli

  outstr do
    expected.times do |count|
      cli.harness.define.spec "fail ##{count + 1}" do
        false
      end
    end
  end

  actual = cli.exit_code
  actual == expected || output
end

spec 'when more than 255 failures, exit status is 255' do
  expected = 255
  cli = new_cli

  output = outstr do
    500.times do
      cli.harness.define.spec 'fail' do
        false
      end
    end
  end

  actual = cli.exit_code
  actual == expected || [$?, output]
end
