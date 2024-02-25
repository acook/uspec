module Uspec
  module Errors
    module_function

    def handle_internal_error error, cli = nil
      message = <<-MSG
      #{error.class} : #{error.message}

      Uspec encountered an internal error, please report this bug: https://github.com/acook/uspec/issues/new

\t#{error.backtrace.join "\n\t"}
      MSG

      result = Uspec::Result.new(message, error, true)

      puts
      warn message

      cli.handle_interrupt! result.raw if cli
      return result
    end

    def handle_file_error error, path, cli = nil
      if SignalException === error || SystemExit === error then
        exit 3
      end

      error_file, error_line, _ = error.backtrace.first.split ?:

      message = <<-MSG
        #{error.class} : #{error.message}

        Uspec encountered an error when loading a test file.
        This is probably a typo in the test file or the file it is testing.

        If you think this is a bug in Uspec please report it: https://github.com/acook/uspec/issues/new

        Error occured when loading test file `#{path}`.
        The origin of the error may be in file `#{error_file}` on line ##{error_line}.

  \t#{error.backtrace[0,3].join "\n\t"}
      MSG

      result = Uspec::Result.new(message, error, true)

      puts
      warn message

      cli.handle_interrupt! result.raw if cli
      return result
    end
  end
end
