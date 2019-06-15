require_relative 'uspec_helper'

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
