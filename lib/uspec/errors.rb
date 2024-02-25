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

      error_file, error_line, _ = error.backtrace.first.split ?:

      message = <<~MSG
        #{error.class} : #{error.message}

        Uspec encountered an error when loading a test file.
        This is probably a typo in the test file or the file it is testing.

        Error occured when loading test file `#{path}`.
        The origin of the error may be in file `#{error_file}` on line ##{error_line}.

        #{bt_indent error.backtrace[0,3]}

        #{MSG_IF_USPEC_BUG}
      MSG

      result = Uspec::Result.new(message, error, true)

      puts
      warn error_indent message

      cli.handle_interrupt! result.raw if cli
      result
    end

    def handle_internal_error error, cli = nil
      message = <<-MSG
      #{error.class} : #{error.message}

      Uspec encountered an internal error, please report this bug: #{MSG_USPEC_BUG_URL}

\t#{error.backtrace.join "\n\t"}
      MSG

      result = Uspec::Result.new(message, error, true)

      puts
      warn message

      cli.handle_interrupt! result.raw if cli
      result
    end

    def msg_source_error error, desc, cli = nil
      error_file, error_line, _ = error.backtrace[4].split ?:

      message = <<~MSG
        #{error.class} : #{error.message}

        Uspec detected a bug in your source code!

        Calling #inspect on an object will recusively call #inspect on its instance variables and contents.
        If one of those contained objects does not have an #inspect method you will see this message.
        You will also get this message if your #inspect method or one of its callees raises an exception.
        This is most likely to happen with BasicObject and its subclasses.

        Error may have occured in test `#{desc}` in file `#{error_file}` on line ##{error_line}.

        #{bt_indent error.backtrace}

        #{MSG_IF_USPEC_BUG}
      MSG

      error_indent message
    end

    def error_indent message
      a = message.split(newline)
      a[0] = "#{hspace}#{a.first}"
      a.join("#{newline}#{hspace}")
    end

    def bt_indent bt
      "#{hspace}" + bt.join("#{newline}#{hspace}") if bt
    end

  end
end
