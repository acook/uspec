require_relative "terminal"
require "toisb"

module Uspec
  class Result
    include Terminal

    PREFIX = "#{Uspec::Terminal.newline}#{Uspec::Terminal.yellow}>\t#{Uspec::Terminal.normal}"

    def initialize spec, raw, ex
      @spec = spec
      @raw = raw
      @ex = ex
      @handler = ::TOISB.wrap raw
      @full_backtrace = false
      @caller = caller
    end
    attr_reader :spec, :raw, :ex, :handler, :full_backtrace

    def pretty
      if raw == true then
        green raw
      elsif raw == false then
        red raw
      elsif pending? then
        yellow 'pending'
      elsif ex == true then
        Uspec::Errors.msg_spec_error raw, desc
      else
        [
          red('Failed'), vspace,
          hspace, 'Spec did not return a boolean value ', newline,
          hspace, 'in spec at ', source.first, vspace,
          hspace, red(subklassinfo), inspector, (Class === raw ? ' Class' : ''), newline
        ].join
      end
    end

    def source
      @source ||= Uspec::Errors.bt_clean @caller
    end

    def subklassinfo
      "#{handler.subklassinfo}: "
    end

    def desc
      if String === spec then
        spec
      elsif Uspec::Spec === spec then
        spec.instance_variable_get :@__uspec_description
      else
        spec.inspect
      end
    end

    # Attempts to inspect an object
    def inspector
      if String === raw && raw.include?(?\n) then
        # if object is a multiline string, display it unescaped
        [
          raw.split(newline).unshift(newline).join(PREFIX), normal, newline,
        ].join
      elsif Exception === raw then
        Uspec::Errors.msg_spec_value raw
      else
        handler.inspector!
      end
    rescue Exception => error
      return handler.simple_inspector if error.message.include? handler.get_id

      Uspec::Errors.msg_source_error error, desc
    end

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

    def inspect
      "#{self.class} for `#{desc}` -> #{pretty}"
    end
  end
end
