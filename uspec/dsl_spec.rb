require_relative "uspec_helper"

spec 'catches errors' do
  output = capture do
    spec 'exception' do
      raise 'test exception'
    end
  end

  output.include?('Exception') || output
end

spec 'catches even non-StandardError-subclass exceptions' do
  output = capture do
    spec 'not implemented error' do
      raise ::NotImplementedError, 'test exception'
    end
  end

  output.include?('Exception') || output
end

spec 'complains when spec block returns non boolean' do
  output = capture do
    spec 'whatever' do
      "string"
    end
  end

  output.include?('Failed') || output
end

spec 'marks test as pending when no block supplied' do
  path =  Pathname.new(__FILE__).parent.join('test_specs', 'pending_spec')

  output = capture do
    exec "bin/uspec #{path}"
  end

  output.include?('1 pending') || output
end

spec 'should not define DSL methods on arbitrary objects' do
  !(Array.respond_to? :spec)
end

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
