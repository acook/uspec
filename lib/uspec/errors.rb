require_relative "terminal"

module Uspec
  module Errors
    module_function

    extend Uspec::Terminal

    MSG_USPEC_BUG_URL = "https://github.com/acook/uspec/issues/new"
    MSG_IF_USPEC_BUG  = "If you think this is a bug in Uspec please report it: #{MSG_USPEC_BUG_URL}"

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
      error_info = error_context error.backtrace.first.split(?:), error.backtrace

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

      error_indent error, message, false
    end

    def error_context error_file, error_bt
      message = <<~MSG
        #{error_origin *error_file}

        #{bt_indent error_bt}

        #{MSG_IF_USPEC_BUG}
      MSG
    end

    def error_origin error_file, error_line, *_
      "The origin of the error may be in file `#{error_file}` on line ##{error_line}."
    end

    def error_indent error, message, first_line_indent = true
      a = message.split(newline)
      a.unshift "#{hspace if first_line_indent}#{error_header error}#{newline}"
      a << ""
      a.join("#{newline}#{hspace}")
    end

    def error_header error
      "#{error.class} : #{error.message}"
    end

    def bt_indent bt
      "#{hspace}" + bt.join("#{newline}#{hspace}") if bt
    end

  end
end
