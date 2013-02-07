require "uspec/version"

module Uspec
  def spec description
    print ' -- ', description

    return puts(': ' + yellow('pending') + vspace) unless block_given?

    begin
      result = yield
    rescue => result
    end

    print ': ', colorize(result, caller), "\n"
  end

  module Color

    def colors
      {
        red: 1,
        green: 2,
        yellow: 3,
        white: 7
      }
    end

    def color hue, text = nil
      esc("3#{colors[hue]};1") + "#{text}#{normal if text}"
    end

    def esc seq
      "\e[#{seq}m"
    end

    def normal text=nil
      esc(0) + text.to_s
    end

    def colorize result, source
      if result == true then
        green result
      elsif result == false then
        red result
      elsif result.is_a? Exception then
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
        text << hspace + line + newline
      end
    end

    def message error
      red(classinfo error) + error.message
    end

    def classinfo object
      "#{classify object} < #{superclass object}: "
    end

    def classify object
      object.is_a?(Module) ? object : object.class
    end

    def superclass object
      classify(object).superclass
    end

    def hspace
      '    '
    end

    def vspace
      newline + newline
    end

    def newline
      $/
    end

    private

    def method_missing name, *args, &block
      if colors.keys.include? name then
        color name, *args
      else
        super
      end
    end

  end

  private

  include Color
end


