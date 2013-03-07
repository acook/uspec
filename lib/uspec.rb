require_relative 'uspec/version'
require_relative 'uspec/formatter'
require_relative 'uspec/dsl'
require_relative 'uspec/stats'

module Uspec
  def self.included object
    warn 'Use extend instead of include.'
    exit
  end

  def self.extended object
    object.extend Uspec::DSL
  end
end

at_exit { exit Uspec::Stats.exit_code }
