require_relative "uspec_helper"

bo = BasicObject.new

spec "#pretty doesn't die when given a BasicObject" do
  result = Uspec::Result.new "BasicObject Result", bo, nil
  expected = "#<BasicObject:"
  actual = result.pretty
  actual.include?(expected) || actual
end

# If we don't prefix the classname with "::", Ruby defines it under an anonymous class
class ::TestObject < BasicObject; end
obj = TestObject.new

spec "ensure BasicObject subclass instances work" do
  result = Uspec::Result.new "BasicObject Subclass Result", obj, nil
  expected = "#<BasicObject/TestObject:"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

spec "display basic info about Object" do
  result = Uspec::Result.new "Object Result", Object.new, nil
  expected = "Object < BasicObject: \e[0m#<Object:"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

spec "display basic info about Array" do
  result = Uspec::Result.new "Array Result", [], nil
  expected = "Array < Object"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

spec "display basic info about Array class" do
  result = Uspec::Result.new "Array Class Result", Array, nil
  expected = "Class < Module: \e[0mArray Class"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

parent = [obj]

spec "ensure parent object of BasicObject subclasses get a useful error message" do
  result = Uspec::Result.new "BasicObject Parent Result", parent, nil
  expected = "BasicObject and its subclasses"
  actual =  result.pretty
  actual.include?(expected) || result.inspector
end

class ::InspectFail; def inspect; raise RuntimeError, "This error is intentional and part of the test."; end; end
inspect_fail = InspectFail.new

spec "display a useful error message when a user-defined inspect method fails" do
  result = Uspec::Result.new "Inspect Fail Result", inspect_fail, nil
  expected = "raises an exception"
  actual =  result.pretty
  actual.include?(expected) || result.inspector
end

spec "display strings more like their actual contents" do
  string = "this string:\nshould display \e\[42;2mproperly"
  expected = /this string:\n.*should display \e\[42;2mproperly/
  result = Uspec::Result.new "Inspect Fail Result", string, nil
  actual =  result.pretty
  actual.match?(expected) || result.inspector
end

def exception_value
  raise "A test exception!"
rescue => err
  return err
end

spec "handles exception values" do
  result = Uspec::Result.new "Exception Value Result", exception_value, nil
  expected = "RuntimeError < StandardError: \e[0mA test exception!"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

spec "handles exception values including backtraces" do
  result = Uspec::Result.new "Exception Value Result", exception_value, nil
  expected = "exception_value"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

spec "handles raised exceptions" do
  result = Uspec::Result.new "Exception Raised Result", exception_value, true
  expected = "RuntimeError < StandardError: \e[0mA test exception!"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

spec "handles raised exceptions without backtraces" do
  result = Uspec::Result.new "Exception Raised Result", Exception.new, true
  expected = "Exception < Object: \e[0mException"
  actual =  result.pretty
  actual.include?(expected) || result.pretty
end

spec "doesn't show 'run' for spec file in stack trace" do
  Uspec::Errors.clean_backtrace!

  result = Uspec::Result.new "No Run Exception Trace Result", exception_value, true
  expected = /uspec.*run/
  actual =  result.pretty

  Uspec::Errors.full_backtrace!
  !actual.match?(expected) || result.pretty
end
