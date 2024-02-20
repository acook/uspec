require_relative 'uspec/version'
require_relative 'uspec/dsl'
require_relative 'uspec/stats'

module Uspec
  def self.included object
    warn 'Use extend instead of include.'
    exit 2
  end

  # this method used to be how we injected the spec method
  def self.extended object
    unless object.is_a? ::Uspec::DSL
      if object.respond_to? :spec
        warn <<-MSG
          Uspec: overwriting a local `spec` method on #{object.class} due to `extend`!
        MSG
      end
      object.extend Uspec::DSL
    end
  end
end
