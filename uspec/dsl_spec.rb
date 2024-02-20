require_relative "uspec_helper"

spec 'when return used in spec, capture it as an error' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'return_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('Invalid return') || output.include?('Spec did not return a boolean value') || output
end

spec 'when break used in spec, capture it as an error' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'break_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('Invalid break') || output.include?('Spec did not return a boolean value') || output
end

spec 'when instance variables are defined in the DSL instance, they are available in the spec body' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'ivar_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('1 successful') || output
end

spec 'when methods are defined in the DSL instance, they are available in the spec body' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'method_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('1 successful') || output
end
