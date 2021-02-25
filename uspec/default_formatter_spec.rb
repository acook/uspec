require_relative "uspec_helper"

bo = BasicObject.new
format = Uspec::DefaultFormatter.new nil

spec "#result doesn't die when given a BasicObject" do
  result = Uspec::Result.new "BasicObject Result", bo, []
  expected = "#<BasicObject:"
  actual = format.result result
  actual.include?(expected) || actual
end

# If we don't prefix the classname with "::", Ruby defines it under an anonymous class
class ::TestObject < BasicObject; end
obj = TestObject.new

spec "ensure BasicObject subclasses work" do
  result = Uspec::Result.new "BasicObject Subclass Result", obj, []
  expected = "#<BasicObject/TestObject:"
  actual = format.result result
  actual.include?(expected) || actual
end

spec "display basic info about Object" do
  result = Uspec::Result.new "Object Result", Object.new, []
  expected = "Object < BasicObject"
  actual = format.result result
  actual.include?(expected) || actual
end

spec "display basic info about Array" do
  result = Uspec::Result.new "Array Result", [], []
  expected = "Array < Object"
  actual = format.result result
  actual.include?(expected) || actual
end

spec "display basic info about Array class" do
  result = Uspec::Result.new "Array Class Result", Array, []
  #expected = "Class < ???" # TODO: Make classes display nicer in TOISB
  expected = "#<Class:Object> < #<Class:BasicObject>: \e[0mArray"
  actual = format.result result
  actual.include?(expected) || actual
end

parent = [obj]

spec "ensure parent object of BasicObject subclasses get a useful error message" do
  result = Uspec::Result.new "BasicObject Parent Result", parent, []
  expected = "BasicObject and its subclasses"
  actual = format.result result
  actual.include?(expected) || actual
end

class ::InspectFail; def inspect; raise RuntimeError, "This error is intentional and part of the test."; end; end
inspect_fail = InspectFail.new

spec "display a useful error message when a user-defined inspect method fails" do
  result = Uspec::Result.new "Inspect Fail Result", inspect_fail, []
  expected = "raises an exception"
  actual = format.result result
  actual.include?(expected) || actual
end

spec "display strings more like their actual contents" do
  expected = "this string:\nshould display \e[42;2mproperly"
  result = Uspec::Result.new "Inspect Fail Result", expected, []
  actual = format.result result
  actual.include?(expected) || actual
end

