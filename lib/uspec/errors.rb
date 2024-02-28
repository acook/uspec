require_relative "terminal"

module Uspec
  module Errors
    module_function

    extend Uspec::Terminal

    MSG_USPEC_BUG_URL = "https://github.com/acook/uspec/issues/new"
    MSG_IF_USPEC_BUG  = "If you think this is a bug in Uspec please report it: #{MSG_USPEC_BUG_URL}"
    TRACE_EXCLUDE_PATTERN = /#{Uspec.libpath.join 'lib'}|#{Uspec.libpath.join 'bin'}/

    def handle_file_error error, path, cli = nil
      if SignalException === error || SystemExit === error then
        exit 3
      end

      error_info = error_context error.backtrace.first.split(?:), error.backtrace[0,3]

      message = <<~MSG
        Uspec encountered an error when loading a test file.
        This is probably a typo in the test file or the file it is testing.

        Error occured when loading test file `#{path}`.
        #{error_info}
      MSG

      result = Uspec::Result.new(message, error, true)

      puts
      warn error_indent error, message

      cli.handle_interrupt! result.raw if cli
      result
    end

    def handle_internal_error error, cli = nil
      error_info = error_context error.backtrace.first.split(?:), error.backtrace, false

      message = <<~MSG
        Uspec encountered an internal error!
        #{error_info}
      MSG

      result = Uspec::Result.new(message, error, true)

      puts
      warn error_indent error, message

      cli.handle_interrupt! result.raw if cli
      result
    end

    def msg_spec_error error, desc
      if error.backtrace then
        origin = error.backtrace.first.split(?:)
      else
        origin = caller.first.split(?:)
      end

      error_info = error_context origin, error.backtrace


      info = <<~MSG
        Error occured when evaluating spec `#{desc}`.
        #{error_info}
      MSG
      body = error_indent error, info

      message = <<~MSG
        #{red 'Exception'}
        #{body}
      MSG

      message
    end

    def msg_spec_value error
      if error.backtrace then
        bt = error.backtrace
      else
        bt = caller
      end

      error_info = white bt_format bt

      message = <<~MSG
      #{error.message}
      #{error_info}
      MSG

      error_indent error, message, header: false
    end

    def msg_source_error error, desc, cli = nil
      error_info = error_context error.backtrace[4].split(?:), error.backtrace

      message = <<~MSG
        Uspec detected a bug in your source code!

        Calling #inspect on an object will recusively call #inspect on its instance variables and contents.
        If one of those contained objects does not have an #inspect method you will see this message.
        You will also get this message if your #inspect method or one of its callees raises an exception.
        This is most likely to happen with BasicObject and its subclasses.

        Error occured when evaluating spec `#{desc}`.
        #{error_info}
      MSG

      error_indent error, message, first_line_indent: false
    end

    def error_context error_file, origin, skip_internal = true
      [
        error_origin(*error_file),
        white(bt_format(origin, skip_internal)),
        MSG_IF_USPEC_BUG
    ].join ?\n
    end

    def error_origin error_file, error_line, *_
      "The origin of the error may be in file `#{error_file}` on line ##{error_line}."
    end

    def error_indent error, message, first_line_indent: true, header: true
      a = message.split(newline)
      a.unshift "\n#{hspace if first_line_indent}#{error_header error}#{newline}" if header
      a << ""
      a.join("#{newline}#{hspace}")
    end

    def error_header error
      "#{red subklassinfo error}#{error.message}"
    end

    def subklassinfo obj
      "#{::TOISB.wrap(obj).subklassinfo}: "
    end

    def bt_format bt, skip_internal = true
      bt_indent bt_clean(bt, skip_internal)
    end

    def bt_indent bt
      "#{newline}#{hspace}" + bt.join("#{newline}#{hspace}") + newline if bt
    end

    def bt_clean bt, skip_internal = true
      bt.inject(Array.new) do |t, line|
        next t if skip_internal && line.match(TRACE_EXCLUDE_PATTERN)
        t << bt_rewrite_caller(line)
      end if bt
    end

    def bt_rewrite_caller line
      return line if full_backtrace?
      if line.match TRACE_EXCLUDE_PATTERN then
        line
      else
        line.sub /file_eval/, 'spec_block'
      end
    end

    def full_backtrace?
      @full_backtrace
    end

    def full_backtrace!
      @full_backtrace = true
    end

    def clean_backtrace!
      @full_backtrace = false
    end
  end
end
