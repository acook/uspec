require_relative "result"

module Uspec
  class Spec

    def initialize dsl, description, &block
      @__uspec_description = description
      @__uspec_harness = dsl

      dsl.define.instance_variables.each do |name|
        self.instance_variable_set(
          name,
          @__uspec_harness.define.instance_variable_get(name)
        ) unless name.to_s.include? '@__uspec'
      end

      dsl.define.methods(false).each do |name|
        self.define_singleton_method name do |*args, &block|
          @__uspec_harness.define.send name, *args, &block
        end unless name.to_s.include? '__uspec'
      end

      if block then
        self.define_singleton_method :__uspec_block, &block
      else
        self.define_singleton_method :__uspec_block do
          raise "Uspec: No block provided for `#{@__uspec_description}`"
        end
      end
    end # initialize

  end
end
