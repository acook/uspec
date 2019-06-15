require_relative 'uspec/version'
require_relative 'uspec/dsl'
require_relative 'uspec/stats'

module Uspec
  def self.included object
    warn 'Use extend instead of include.'
    exit 2
  end

  def self.extended object
    object.extend Uspec::DSL
  end
end

at_exit do
  failures = Uspec::Stats.exit_code
  status = $!.respond_to?(:status) ? $!.status : 0
  errors = ($! && $!.cause == nil) ? 0 : 1
  code = [failures, status, errors].max
  exit code
end
