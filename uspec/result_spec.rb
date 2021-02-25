require_relative "uspec_helper"

bo = BasicObject.new

spec "#pretty doesn't die when given a BasicObject" do
  result = Uspec::Result.new "BasicObject Result", bo, []
  expected = "#<BasicObject:"
  actual = result.pretty
  actual.include?(expected) || actual
end

# If we don't prefix the classname with "::", Ruby defines it under an anonymous class
class ::TestObject < BasicObject; end
obj = TestObject.new

spec "ensure BasicObject subclasses work" do
  result = Uspec::Result.new "BasicObject Subclass Result", obj, []
  expected = "#<BasicObject/TestObject:"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

parent = [obj]

spec "ensure parent object of BasicObject subclasses get a useful error message" do
  result = Uspec::Result.new "BasicObject Parent Result", parent, []
  expected = "BasicObject and its subclasses"
  actual =  result.pretty
  actual.include?(expected) || result.inspector
end

class ::InspectFail; def inspect; raise RuntimeError, "This error is intentional and part of the test."; end; end
inspect_fail = InspectFail.new

spec "display a useful error message when a user-defined inspect method fails" do
  result = Uspec::Result.new "Inspect Fail Result", inspect_fail, []
  expected = "raises an exception"
  actual =  result.pretty
  actual.include?(expected) || result.inspector
end
