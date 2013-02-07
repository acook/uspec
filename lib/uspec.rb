require "uspec/version"

module Uspec
  def spec description
    return puts("#{yellow('pending:')} #{description}") unless block_given?

    print '-- ', description

    begin
      result = yield
    rescue => result
    end

    print ': ', colorize(result), "\n"
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

    def colorize result
      if result == true then
        green result
      elsif result == false then
        red result
      elsif result.is_a? Exception then
        red("error (exception)") + vspace + hspace + result.message + vspace + white(trace result)
      else
        red("error (unknown result)") + vspace + hspace + result.to_s + vspace
      end
    end

    def trace error
      error.backtrace.inject(String.new) do |text, line|
        text << hspace + line + "\n"
      end
    end

    def hspace
      '    '
    end

    def vspace
      "\n\n"
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


