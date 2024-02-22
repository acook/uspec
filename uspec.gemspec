# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "uspec/version"

Gem::Specification.new do |gem|
  gem.name          = "uspec"
  gem.version       = Uspec::VERSION
  gem.authors       = ["Anthony M. Cook"]
  gem.email         = ["github@anthonymcook.com"]
  gem.description   = %q{Uspec is a shiny little spec framework for your apps! Unlike other testing frameworks there's no need for matchers, there can only be one assertion per test, and you never have to worry that your tests lack assertions.}
  gem.summary       = %q{a shiny little spec framework for your apps!}
  gem.homepage      = "http://github.com/acook/uspec#readme"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # due to require_relative semantics in 1.9.x and issues with BasicObject support in 2.0
  # technically should still work in 2.0 but some of the test suite won't pass
  gem.required_ruby_version = ">= 2.1"

  gem.add_dependency "that_object_is_so_basic", ">= 0.0.5"
end
