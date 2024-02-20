require_relative 'uspec_helper'

spec 'stats can be inspected' do
  actual = @__uspec_dsl.__uspec_stats.inspect
  actual.include?("Failures:") || actual
end
