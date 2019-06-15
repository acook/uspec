require_relative "uspec_helper"

result = Uspec::Result.new "BasicObject Test", BasicObject.new, []

spec "#colorize doesn't die when given a BasicObject" do
    expected = "#<BasicObject:"
    actual = result.colorize
    actual.include?(expected) || actual
end
