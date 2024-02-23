require_relative 'uspec_helper'

spec 'stats can be inspected' do
  actual = @__uspec_harness.stats.inspect
  actual.include?("failure") || actual
end

spec 'stats inspect does not have any stray whitespace' do
  output = @__uspec_harness.stats.inspect
  match = output.match /(.*(?:  |\n))/m
  match == nil || match
end
