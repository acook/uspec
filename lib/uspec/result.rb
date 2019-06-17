require_relative "terminal"

module Uspec
  class Result
    include Terminal

    def initialize spec, raw, source
      @spec = spec
      @raw = raw
      @source = source
    end
    attr_reader :spec, :raw, :source

    def pretty
      if raw == true then
        green raw
      elsif raw == false then
        red raw
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
          red('Unknown Result'), vspace,
          hspace, 'Spec did not return a boolean value ', newline,
          hspace, 'in spec at ', source.first, vspace,
          hspace, red(klassinfo), inspector, newline
        ].join
      end
    end

    def trace
      raw.backtrace.inject(String.new) do |text, line|
        text << "#{hspace}#{line}#{newline}"
      end
    end

    def message
      "#{red klassinfo}#{raw.message}"
    end

    def klassinfo
      superklass ? "#{klass} < #{superklass}: " : "#{klass}: "
    end

    # Attempts to inspect an object
    def inspector
      klass && klass.public_method_defined?(:inspect) ? raw.inspect : "#<#{klass}:0x#{get_id}>"
    rescue Exception => error
      return "#<#{klass}:0x#{get_id}>" if error.message.include? get_id

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

    # Returns the class of the object if it isn't already a class
    def klass
      Module === raw ? raw : ancestor_klasses[1]
    end

    # Returns the superclass of the object
    def superklass
      ancestor_klasses[2]
    end

    # Gets the object ID of an object
    def get_id
      raw.__id__.to_s(16) rescue 0
    end

    # Obtain the singleton class of an object
    def singleton
      @singleton ||= (class << raw; self; end) rescue raw.class
    end

    def ancestor_klasses
      @ancestor_klasses ||= ancestors.select{|a| a.is_a? Class}
    end

    # Collects the ancestors of an object
    def ancestors
      @ancestors ||= safe_send singleton, :ancestors
    end

    # Works around BasicObject and other objects that are missing/overwrite important methods
    def safe_send object, method, *args, &block
      (Module === object ? Module : Object).instance_method(method).bind(object).call(*args, &block)
    end

    def inspect
      "#{self.class} for `#{spec}` -> #{pretty}"
    end
  end
end
