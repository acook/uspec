require_relative "result"

module Uspec
  class Spec

    def initialize harness, description, &block
      @__uspec_description = description
      @__uspec_harness = harness
      ns = harness.define

      ns.instance_variables.each do |name|
        self.instance_variable_set(
          name,
          ns.instance_variable_get(name)
        ) unless name.to_s.include? '@__uspec'
      end

      ns.methods(false).each do |name|
        self.define_singleton_method name do |*args, &block|
          ns.send name, *args, &block
        end unless name.to_s.include? '__uspec'
      end

      if block then
        self.define_singleton_method :__uspec_block, &block
      else
        self.define_singleton_method :__uspec_block do
          raise NotImplementedError, "Uspec: No block provided for `#{@__uspec_description}`"
        end
      end
    end # initialize

  end
end
