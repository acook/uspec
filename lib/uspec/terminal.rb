module Uspec
  module Terminal
  module_function

    def colors
      {
        red: 1,
        green: 2,
        yellow: 3,
        white: 7
      }
    end

    def color hue, text = nil
      "#{esc "3#{colors[hue]};1"}#{text}#{normal unless text.nil?}"
    end

    def esc seq
      "\e[#{seq}m"
    end

    def normal text=nil
      "#{esc 0}#{text}"
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
