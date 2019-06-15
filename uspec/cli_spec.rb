require_relative 'uspec_helper'
require 'open3'

spec 'shows usage' do
  output = capture do
    exec 'bin/uspec -h'
  end

  output.include? 'usage'
end

spec 'runs a path of specs' do
  output = capture do
    path = Pathname.new(__FILE__).parent.parent.join('example_specs').to_s
    Uspec::CLI.run_specs Array(path)
  end

  output.include? 'I love passing tests'
end

spec 'runs an individual spec' do
  output = capture do
    path =  Pathname.new(__FILE__).parent.parent.join('example_specs', 'example_spec.rb').to_s
    Uspec::CLI.run_specs Array(path)
  end

  output.include? 'I love passing tests'
end

spec 'exits with failure status if a test has a broken require' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'broken_require_spec')

  capture do
    exec "bin/uspec #{path}"
  end

  $?.exitstatus == 1 || $?
end

spec 'displays information about test file with broken require' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'broken_require_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include? 'cannot load such file'
end