require_relative 'spec_helper'

spec 'I love passing tests' do
  true
end

spec "This is an idea, but I haven't written the test yet"

spec 'Failing tests display a red' do
  false
end

spec 'Inspects non-boolean value that the spec block returns' do
  'non-boolean value'
end

spec 'Displays informative exceptions' do
  class ExampleError < RuntimeError; end
  raise ExampleError
end

