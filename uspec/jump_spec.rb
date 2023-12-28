require_relative "uspec_helper"

spec 'when return used in spec, capture it as an error' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'return_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('Invalid return') || output.split("\n").unshift("\t>\t").join("\n\t>\t")
end

spec 'when break used in spec, capture it as an error' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'break_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('Invalid break') || output.split("\n").unshift("\t>\t").join("\n\t>\t")
end
