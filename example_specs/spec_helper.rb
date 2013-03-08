require 'bundler/setup'

Bundler.require :development, :test

require 'uspec'

Dir.chdir File.dirname(__FILE__)

extend Uspec

