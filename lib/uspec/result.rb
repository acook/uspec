require_relative "terminal"
require "toisb"

module Uspec
  class Result
    include Terminal

    PREFIX = "#{Uspec::Terminal.newline}#{Uspec::Terminal.yellow}>\t#{Uspec::Terminal.normal}"
    TRACE_EXCLUDE_PATTERN = /#{Uspec.libpath.join 'lib'}|#{Uspec.libpath.join 'bin'}/

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
        [
          red('Exception'), vspace,
          hspace, 'Spec encountered an Exception ', newline,
          hspace, 'in spec at ', source.first, vspace,
          hspace, message, vspace,
          white(trace)
        ].join
      else
        [
          red('Failed'), vspace,
          hspace, 'Spec did not return a boolean value ', newline,
          hspace, 'in spec at ', source.first, vspace,
          hspace, red(subklassinfo), inspector, (Class === raw ? ' Class' : ''), newline
        ].join
      end
    end

    def trace
      @backtrace ||= indent_bt clean_bt(raw.backtrace, !full_backtrace)
    end

    def source
      @source ||= clean_bt @caller
    end

    def indent_bt bt
      bt.inject(String.new) do |text, line|
        text << "#{hspace}#{line}#{newline}"
      end if bt
    end

    def clean_bt bt, skip_internal = true
      bt.inject(Array.new) do |t, line|
        next t if skip_internal && line.match(TRACE_EXCLUDE_PATTERN)
        t << rewrite_bt_caller(line)
      end if bt
    end

    def rewrite_bt_caller line
      return line if full_backtrace
      if line.match TRACE_EXCLUDE_PATTERN then
        line
      else
        line.sub /file_eval/, 'spec_block'
      end
    end

    def message
      "#{red subklassinfo}#{raw.message}"
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
        [
          raw.message, vspace,
          white(trace),
          normal, newline,
      ].join
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
