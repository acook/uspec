require_relative "result"

module Uspec
  class Spec

    def initialize dsl, &block

      @__uspec_dsl = dsl

      dsl.instance_variables.each do |name|
        self.instance_variable_set(name, @__uspec_dsl.instance_variable_get(name)) unless name.to_s.include? '@__uspec'
      end

      dsl.methods(false).each do |name|
        self.define_singleton_method name do |*args, &block|
          @__uspec_dsl.send name, *args, &block
        end unless name.to_s.include? '__uspec'
      end

      self.define_singleton_method :spec_block, &block
    end

    def spec description, &block
      @__uspec_dsl.spec description, &block
    end
  end
end
