require_relative "terminal"
require "toisb"

module Uspec
  class Result
    include Terminal

    def initialize spec, raw, source, obj = nil
      @spec = spec
      @raw = raw
      @source = source
      @obj = obj
      @handler = ::TOISB.wrap raw
    end
    attr_reader :spec, :raw, :source, :handler

    def success?
      raw == true
    end

    def failure?
      raw != true && !@pending
    end

    def pending?
      !!@pending
    end

    def pending!
      @pending = true
    end

    def abnormal?
      !!@obj
    end

    def inspect
      "#{self.class} for `#{spec}` -> #{handler.inspector}"
    end
  end
end
