require_relative "uspec_helper"

result = Uspec::Result.new "BasicObject Test", BasicObject.new, []

spec "#pretty doesn't die when given a BasicObject" do
    expected = "#<BasicObject:"
    actual = result.pretty
    actual.include?(expected) || actual
end
