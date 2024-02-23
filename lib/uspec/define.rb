module Uspec
  class Define

    def initialize harness
      @__uspec_harness = harness
    end

    def spec description, &block
      @__uspec_harness.spec description, &block
    end
  end
end