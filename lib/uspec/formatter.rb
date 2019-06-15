require_relative "terminal"

module Uspec
  class Formatter
    include Terminal

    def colorize result, source
      if result == true then
        green result
      elsif result == false then
        red result
      elsif is_class result, Exception then
        [
          red('Exception'), vspace,
          hspace, 'Spec encountered an Exception ', newline,
          hspace, 'in spec at ', source.first, vspace,
          hspace, message(result), vspace,
          white(trace result)
        ].join
      else
        [
          red('Unknown Result'), vspace,
          hspace, 'Spec did not return a boolean value ', newline,
          hspace, 'in spec at ', source.first, vspace,
          hspace, red(classinfo(result)), inspector(result), newline
        ].join
      end
    end

    def trace error
      error.backtrace.inject(String.new) do |text, line|
        text << "#{hspace}#{line}#{newline}"
      end
    end

    def message error
      "#{red classinfo error}#{error.message}"
    end

    def classinfo object
      klass = superclass object
      klass ? "#{classify object} < #{superclass object}: " : "#{classify object}: "
    end

    # Attempts to inspect an object
    def inspector object
      accepts(object, :inspect) ? object.inspect : "#<#{classify object}:0x#{get_id object}>"
    end

    # Returns the class of the object if it isn't already a class
    def classify object
      is_class(object, Module) ? object : safe_send(object, :class)
    end

    # Returns the superclass of the object
    def superclass object
      ancestors(object)[2]
    end

    # Returns true if object is of type klass
    def is_class object, klass
      safe_send object, :is_a?, klass
    end

    # Returns true if the object accepts the given message
    def accepts object, message
      safe_send object, :respond_to?, message
    end

    # Gets the object ID of an object
    def get_id object
      object.__id__.to_s(16) rescue 0
    end

    # Obtain the singleton class of an object
    def singleton object
      class << object; self; end
    end

    # Collects the ancestors of an object
    def ancestors object
      safe_send singleton(object), :ancestors
    end

    # Works around BasicObject and other objects that are missing/overwrite important methods
    def safe_send object, method, *args, &block
      (Module === object ? Module : Object).instance_method(method).bind(object).call(*args, &block)
    end
  end
end
