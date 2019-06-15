module Uspec
  class Formatter
    def colors
      {
        red: 1,
        green: 2,
        yellow: 3,
        white: 7
      }
    end

    def color hue, text = nil
      "#{esc "3#{colors[hue]};1"}#{text}#{normal}"
    end

    def esc seq
      "\e[#{seq}m"
    end

    def normal text=nil
      "#{esc 0}#{text}"
    end

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
          hspace, red(classinfo(result)), result.inspect, newline
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
      "#{classify object} < #{superclass object}: "
    end

    # Returns the class of the object if it isn't already a class
    # Compatible with BasicObject
    def classify object
      is_class(object, Module) ? object : ::Kernel.instance_method(:class).bind(object).call
    end

    # Returns the superclass of the object
    # Compatible with BasicObject
    def superclass object
      ::Class.instance_method(:superclass).bind(classify(object)).call
    end

    # Returns true if object is of type klass
    # Compatible with BasicObject
    def is_class object, klass
      ::Kernel.instance_method(:is_a?).bind(object).call(klass)
    end

    def hspace
      '    '
    end

    def vspace
      "#{newline}#{newline}"
    end

    def newline
      $/
    end

    def method_missing name, *args, &block
      if colors.keys.include? name then
        color name, *args
      else
        super
      end
    end

  end
end
