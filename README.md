Uspec
=====

Uspec is a shiny little testing framework for your apps!

    Anthony M. Cook 2013

Philosophy / Why Uspec?
-----------------------

Unlike other testing frameworks there's no need for matchers, there can only be one assertion per test, and you never have to worry that your tests lack assertions.

That's because when the `spec` block is evaluated the return value is used (in a very ruby-like way) to determine the validity of the statement. Standard Ruby comparisons are your friend! No more digging around in your test framework's documentation to figure out what matcher you're supposed to use.

You can't tell here in the docs, but Uspec's output is in beautiful ansi technicolor, with red for failures, green for successes, and yellow for pending specs. Download it and give it a show, its painless and uber easy to use. :)

Usage
-----

I suggest creating a `uspec` directory in your project folder to put your specs in. Then you'll need this incantation:

```ruby
require 'uspec'
extend Uspec
```

You can slot it in the top of your test file, or if you have other setup code you can put it in a `uspec_helper.rb` and `relative_require 'uspec_helper'` in them instead.

Then all you have to do is put in your specs:

```ruby
spec 'AwesomeMcCoolname.generate creates a cool name' do
  AwesomeMcCoolname.generate.include? 'Cool'
end
```

If it passes:

```
 -- AwesomeMcCoolname.generate creates a cool name: true
```

If it fails:

```
 -- AwesomeMcCoolname.generate creates a cool name: false
```

If it throws an error:

```
 -- AwesomeMcCoolname.generate creates a cool name: Exception
 
    Encountered an Exception while running spec
    at uspec/awesome_mc_coolname_spec.rb:3: in `<main>'
    
    RuntimeError < StandardError: 'wtf'
    
    /Users/Dude/Projects/Awesome/lib/awesome_mc_coolname.rb:18:in `explode'
    uspec/awesome_mc_coolname_spec.rb:4:in `block in <main>'
```

If you create a spec that doesn't return a boolean value (`nil` doesn't count either!) like this:

```ruby
spec 'AwesomeMcCoolname.generate creates a cool name' do
  AwesomeMcCoolname.generate =~ /Badass/
end
```

Then Uspec will let you know:

```
 -- AwesomeMcCoolname.generate creates a badass name: Unknown Result
 
    Spec did not return a boolean value
    at uspec/awesome_mc_coolname_spec.rb:6: in `<main>'
    
    Integer < Numeric: 5
```

If you aren't ready to fill out a spec, maybe as a reminder to add functionality later, just leave off the block and it will be marked as `pending`:

```ruby
spec 'a feature I have not implemented yet'
```

output:

```
 -- a feature I have not implemented yet: pending
```

Installation
------------

Add this line to your application's Gemfile:

    gem 'uspec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uspec

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
