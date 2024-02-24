require_relative 'uspec_helper'

def stats_object
  Uspec::Stats.new
end

spec 'stats can be inspected' do
  # this is a regression test
  # the issue it covers occured because of a refactor where stats had a custom inspect method
  # stats no longer has a custom inspect method, but this makes sure that nothing breaks
  actual = @__uspec_harness.stats.inspect
  actual.include?("failure") || actual
end

spec 'stats inspect does not have any stray whitespace' do
  output = stats_object.inspect
  match = output.match /(.*(?:  |\n))/m
  match == nil || match
end
