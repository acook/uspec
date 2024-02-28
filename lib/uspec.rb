module Uspec
  def self.included object
    warn 'Use extend instead of include.'
    exit 2
  end

  # this method used to be how we injected the spec method
  def self.extended object
    #unless object.respond_to? :spec
    #  object.extend Uspec::DSL
    #end
  end

  def self.libpath
    Pathname.new(__FILE__).dirname.dirname
  end
end

require_relative 'uspec/version'
require_relative 'uspec/errors'
require_relative 'uspec/harness'
require_relative 'uspec/define'
require_relative 'uspec/stats'
