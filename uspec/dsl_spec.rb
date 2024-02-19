require_relative "uspec_helper"

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
