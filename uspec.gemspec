# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "uspec/version"

Gem::Specification.new do |gem|
  gem.name          = "uspec"
  gem.version       = Uspec::VERSION
  gem.authors       = ["Anthony Cook"]
  gem.email         = ["anthonymichaelcook@gmail.com"]
  gem.description   = %q{Uspec is a shiny little spec framework for your apps! Unlike other testing frameworks there's no need for matchers, there can only be one assertion per test, and you never have to worry that your tests lack assertions.}
  gem.summary       = %q{a shiny little spec framework for your apps!}
  gem.homepage      = "http://github.com/acook/uspec#readme"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-doc"
end
