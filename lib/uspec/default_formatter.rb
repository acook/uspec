require_relative "formatter"
require_relative "terminal"

module Uspec
  class DefaultFormatter < Formatter
    T = Uspec::Terminal

    def pre_suite options
      @out_of_band_failures = []
      nil
    end

    def pre_file path, stats
      @pre_file_failures = stats.failure.dup
      nil
    end

    def file_prefix
    end

    def file path
      path.basename path.extname
    end

    def file_suffix
      ":\n"
    end

    def test_prefix
      " -- "
    end

    def test description, tags = []
      description
    end

    def test_suffix
      ?:
    end

    def result_prefix
      " "
    end

    def result robj
      return T.yellow "pending" if robj.pending?

      value = robj.raw
      case value
      when true
        T.green value
      when false
        T.red value
      when Exception
        [
          T.red('Exception'), T.vspace,
          T.hspace, 'Spec encountered an Exception ', T.newline,
          T.hspace, 'in spec at ', robj.source.first, T.vspace,
          T.hspace, message(robj), T.vspace,
          T.white(trace robj)
        ].join
      else
        [
          T.red('Failed'), T.vspace,
          T.hspace, 'Spec did not return a boolean value ', T.newline,
          T.hspace, 'in spec at ', robj.source.first, T.vspace,
          T.hspace, T.red(subklassinfo robj), inspector(robj), T.newline
        ].join
      end
    end

    def result_suffix
      ?\n
    end

    def post_file path, stats
      out_of_band_failures = (stats.failure - @pre_file_failures).select(&:abnormal?).map do |r|
        result r
      end
      @out_of_band_failures << out_of_band_failures
      out_of_band_failures.join "\n\n"
    end

    def post_suite options
      (options.stats.failure - @out_of_band_failures).select(&:abnormal?).map do |r|
        result r
      end.join "\n\n"
    end

    def summary stats
      [
        "test summary: ",
        Uspec::Terminal.green("#{stats.success.size} successful"),
        ", ",
        Uspec::Terminal.red("#{stats.failure.size} failed"),
        ", ",
        Uspec::Terminal.yellow("#{stats.pending.size} pending"),
        "\n"
      ].join
    end

    ######################################

    def trace(robj)
      robj.raw.backtrace.inject(String.new) do |text, line|
        text << "#{T.hspace}#{line}#{T.newline}"
      end
    end

    def message(robj)
      "#{T.red subklassinfo(robj)}#{robj.raw.message}"
    end

    def subklassinfo(robj)
      "#{robj.handler.subklassinfo}: "
    end

    def inspector(robj)
      if String === robj.raw && robj.raw.include?(?\n) then
        # if object is a multiline string, display it unescaped
        [
          T.vspace,
          T.hspace, T.yellow('"""'), T.newline,
          robj.raw, T.normal, T.newline,
          T.hspace, T.yellow('"""')
        ].join
      else
        super
      end
    end
  end
end
