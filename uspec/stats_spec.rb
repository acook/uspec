require_relative 'uspec_helper'

spec 'stats can be inspected' do
  actual = @__uspec_dsl.__uspec_stats.inspect
  actual.include?("failure") || actual
end

spec 'stats inspect does not have any stray whitespace' do
  output = @__uspec_dsl.__uspec_stats.inspect
  match = output.match(/  |\n/)
  match == nil || match
end
