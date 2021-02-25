require_relative "terminal"
require "toisb"

module Uspec
  class Result
    include Terminal

    def initialize spec, raw, source
      @spec = spec
      @raw = raw
      @source = source
      @handler = ::TOISB.wrap raw
    end
    attr_reader :spec, :raw, :source, :handler

    def pretty
      if raw == true then
        green raw
      elsif raw == false then
        red raw
      elsif pending? then
        yellow 'pending'
      elsif Exception === raw then
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
          hspace, red(subklassinfo), inspector, newline
        ].join
      end
    end

    def trace
      raw.backtrace.inject(String.new) do |text, line|
        text << "#{hspace}#{line}#{newline}"
      end
    end

    def message
      "#{red subklassinfo}#{raw.message}"
    end

    def subklassinfo
      "#{handler.subklassinfo}: "
    end

    # Attempts to inspect an object
    def inspector
      if String === raw && raw.include?(?\n) then
        # if object is a multiline string, display it unescaped
        [
          vspace,
          hspace, yellow('"""'), newline,
          raw, normal, newline,
          hspace, yellow('"""')
        ].join
      else
        handler.inspector!
      end
    rescue Exception => error
      return handler.simple_inspector if error.message.include? handler.get_id

      error_file, error_line, _ = error.backtrace[4].split ?:

      <<-MSG

      #{error.class} : #{error.message}

      Uspec detected a bug in your source code!
      Calling #inspect on an object will recusively call #inspect on its instance variables and contents.
      If one of those contained objects does not have an #inspect method you will see this message.
      You will also get this message if your #inspect method or one of its callees raises an exception.
      This is most likely to happen with BasicObject and its subclasses.

      If you think this is a bug in Uspec please report it: https://github.com/acook/uspec/issues/new

      Error may have occured in test `#{spec}` in file `#{error_file}` on line ##{error_line}.

\t#{error.backtrace.join "\n\t"}
      MSG
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
      "#{self.class} for `#{spec}` -> #{pretty}"
    end
  end
end
