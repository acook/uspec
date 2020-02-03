Uspec
=====

Uspec is a shiny little testing framework for your apps!

[![Gem Version](https://img.shields.io/gem/v/uspec.svg?style=for-the-badge)](https://rubygems.org/gems/uspec/)
[![Build Status](https://img.shields.io/travis/acook/uspec.svg?style=for-the-badge)](https://travis-ci.org/acook/uspec)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/acook/uspec.svg?style=for-the-badge)](https://codeclimate.com/github/acook/uspec)

Philosophy / Why Uspec?
-----------------------

> Uspec is just Ruby!

Unlike other testing frameworks there's no need for special matchers,
there can only be one assertion per test,
and you never have to worry that your tests lack assertions.

That's because when the `spec` block is evaluated the return value is used (in a very ruby-like way)
to determine if the test has passed or failed. Standard Ruby comparisons are your friend!
No more digging around in your test framework's documentation to figure out what matcher you're supposed to use.
This also means *no monkey patching* core classes!

Uspec's output is in beautiful ansi technicolor,
with red for failures, green for successes, and yellow for pending specs. Here's a screenshot:

![Screenshot!](http://i.imgur.com/M2F5YvO.png)

Uspec is tiny, painless, and easy to use. Download it and give it a try!

Example
-------

Uspec is **just Ruby**. The DSL is minimal - there's only one method to remember!

Writing a spec is easy:

```ruby
spec 'AwesomeMcCoolname.generate creates a cool name' do
  AwesomeMcCoolname.generate.include? 'Cool'
end
```

That's it!

Installation
------------

Add this line to your application's Gemfile:

    gem 'uspec'

And then execute:

    $ bundle

Or install it directly with:

    $ gem install uspec


Quickstart
----------

0. Create a `uspec` directory to keep your specs in.
1. Name your specs ending with `_spec.rb`.
2. Write some specs in Ruby using the `spec` method (example above).
2. Use the included `uspec` executable to run your specs.

**Hint:** A lot of people also put `require_relative 'spec_helper'` at the top of their test files for sharing code between tests.

Commandline Usage
-----------------

```
$ uspec --help
uspec - minimalistic ruby testing framework
usage: uspec [<file_or_path>...]
```

- Without arguments the `uspec` command will automatially look for a `uspec` directory and load any `*_spec.rb` files inside them.
- You can also pass in arbitrary files and it will attempt to run them as specs.
- If you pass in directories `uspec` will scan for and run any specs inside them.
- Uspec will return the number of failures as its status code to the commandline, 0 if none.

Output
------

A brief explanation of `uspec`'s output to show you what it can do!

### Success

If a spec passes:

```
 -- AwesomeMcCoolname.generate creates a cool name: true
```

### Failure

If a spec fails:

```
 -- AwesomeMcCoolname.generate creates a cool name: false
```

### Exception

If the spec throws an error:

```
 -- AwesomeMcCoolname.generate creates a cool name: Exception

    Encountered an Exception while running spec
    at uspec/awesome_mc_coolname_spec.rb:3: in `<main>'

    RuntimeError < StandardError: 'wtf'

    /Users/Dude/Projects/Awesome/lib/awesome_mc_coolname.rb:18:in `explode'
    uspec/awesome_mc_coolname_spec.rb:4:in `block in <main>'
```

### Non-boolean values

If you create a spec that doesn't return a boolean value (`nil` doesn't count either!) like this:

```ruby
spec 'AwesomeMcCoolname.generate creates a cool name' do
  AwesomeMcCoolname.generate =~ /Badass/
end
```

Then Uspec will let you know:

```ruby
 -- AwesomeMcCoolname.generate creates a badass name: Unknown Result

    Spec did not return a boolean value
    at uspec/awesome_mc_coolname_spec.rb:6: in `<main>'

    Integer < Numeric: 5
```

### Pending

If you aren't ready to fill out a spec, maybe as a reminder to add functionality later, just leave off the block and it will be marked as `pending`:

```ruby
spec 'a feature I have not implemented yet'
```

When you run the test Uspec will helpfully display:

```
 -- a feature I have not implemented yet: pending
```

Tips & Tricks
-------------

Because there's no matchers and only one method there's no need for specialized reference documentation, but here are some ideas to get you going!

### String matching

Instead of `=~` (which returns either an `Integer` index or `nil`) Ruby has the nifty `include?` method, which returns a boolean:

```ruby
spec 'AwesomeMcCoolname.generate creates a cool name' do
  AwesomeMcCoolname.generate.include? 'Badass'
end
```

### Regex matching

If you really need to regex, you can always use Ruby's `!!` idiom to coerce a boolean out of any result,
but its more precise to specify the index if you know it.
And you can always toss in an `||` to drop in more information if a comparison fails too:

```ruby
spec 'AwesomeMcCoolname.generate creates a cool name' do
  index = AwesomeMcCoolname.generate =~ /Badass/
  index == 0 || index
end
```

### Exceptions

What if you want to test that an error has occured? Just use Ruby!

```ruby
spec 'calling AwesomeMcCoolname.awesomeness without specifying the awesomeness level should explode' do
  begin
    AwesomeMcCoolname.awesomeness
  rescue ArgumentError => error
    error.message.include?("Needs awesomeness level!") || raise
  end
end
```

If there's no error, then Uspec will see the result of the method call (whatever it might be).
If the wrong Exception is raised, then because of reraising (by just calling `raise` without parameters),
Ruby will dutifully pass along the error for Uspec to display.

Mocks, Spies, Stubs, and More!
-----------------------

Since `uspec` is a very straight forward testing utility it is easy to use any of the standard Ruby mocking frameworks with it. However, the [Impasta gem](https://github.com/acook/impasta) was made specifically for simple but comprehensive mocking, stubbing, and spying.

Assertions & Debugging
----------------------

You can also use `uspec` to track assertions in an application or any object you want. Every spec block you use will be tracked and recorded. It's really no problem at all to do.

You can load Uspec's features directly into a class and use its DSL:

```ruby
require 'uspec'

class MyFoo
  extend Uspec::DSL

  def assert
    spec 'foo is valid' do
      false
    end
  end
end

MyFoo.new.assert
```

Assertions will be displayed as they occur, success or failure along with any informative output.
If there are any specs that fail, when your application exits its error code will equal the number of failures.

```
$ ruby foo.rb
 -- foo is valid: false
$ echo $?
1
```

Uspec is just Ruby
------------------

If for some reason you don't want to use the `uspec` command, you can `require 'uspec'` and `extend Uspec::DSL`.
From there you can just run the file with ruby: `ruby my_test_spec.rb`

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Author
------

> Anthony M. Cook 2013-2020
