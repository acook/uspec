require_relative "uspec_helper"

formatter = Uspec::Formatter.new

spec "#colorize doesn't die when given a BasicObject" do
    expected = "#<BasicObject:"
    actual = formatter.colorize(BasicObject.new, [])
    actual.include?(expected) || actual
end