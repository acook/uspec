require_relative 'spec_helper'

spec 'I love passing tests! Passing tests return `true`' do
  true
end

spec "This is an idea, but I haven't written the test yet"

spec 'This is a failing test. Failing tests return `false`' do
  false
end

spec 'Non-boolean values are shown in detail' do
  'non-boolean value'
end

spec 'Exceptions are handled and displayed' do
  class ExampleError < RuntimeError; end
  raise ExampleError, "an example error for demonstration"
end
