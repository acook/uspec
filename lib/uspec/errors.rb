require_relative "terminal"

module Uspec
  module Errors
    module_function

    extend Uspec::Terminal

    MSG_USPEC_BUG_URL = "https://github.com/acook/uspec/issues/new"
    MSG_IF_USPEC_BUG  = "If you think this is a bug in Uspec please report it: #{MSG_USPEC_BUG_URL}"
    TRACE_EXCLUDE_PATTERN = /#{Uspec.libpath.join 'lib'}|#{Uspec.libpath.join 'bin'}/

    def handle_file_error error, path, cli = nil
      error_info = error_context error

      message = <<~MSG
        Uspec encountered an error when loading a test file.
        This is probably a typo in the test file or the file it is testing.

        Error occured when loading test file `#{path}`.
        #{error_info}
      MSG

      handle_error message, error, cli
    end

    def handle_internal_error error, cli = nil
      error_info = error_context error, skip_internal: false

      message = <<~MSG
        Uspec encountered an internal error!

        #{error_info}
      MSG

      handle_error message, error, cli
    end

    def handle_error message, error, cli
      result = Uspec::Result.new(message, error, true)

      puts
      warn error_format error, message, leading_newline: false

      cli.handle_interrupt! result.raw if cli
      result
    end

    def msg_spec_error error, desc
      error_info = error_context error

      info = <<~MSG
        Error occured when evaluating spec `#{desc}`.
        #{error_info}
      MSG
      body = error_format error, info, first_line_indent: false

      message = <<~MSG
        #{red 'Exception'}
        #{body}
      MSG

      message
    end

    def msg_spec_value error
      error_info = white bt_format(bt_get error).chomp

      message = <<~MSG
        #{error.message}
        #{error_info}
      MSG

      error_format error, message, header: false
    end

    def msg_source_error error, desc, cli = nil
      error_info = error_context error

      message = <<~MSG
        Uspec detected a bug in your source code!

        Calling #inspect on an object will recusively call #inspect on its instance variables and contents.
        If one of those contained objects does not have an #inspect method you will see this message.
        You will also get this message if your #inspect method or one of its callees raises an exception.
        This is most likely to happen with BasicObject and its subclasses.

        Error occured when evaluating spec `#{desc}`.
        #{error_info}
      MSG

      error_format error, message, first_line_indent: false
    end

    def error_context error, skip_internal: true
      bt = bt_get error
      error_line = bt.first.split(?:)
      [
        error_origin(*error_line),
        white(bt_format(bt, skip_internal)),
        MSG_IF_USPEC_BUG
      ].join ?\n
    end

    def bt_get error
      error.backtrace || caller[3..-1]
    end

    def error_origin error_file, error_line, *_
      "The origin of the error may be in file `#{error_file}` on line ##{error_line}."
    end

    def error_format error, message, first_line_indent: true, leading_newline: true, header: true
      h = ""

      if header then
        h << newline if leading_newline
        h << hspace if first_line_indent
        h << error_header(error)
        h << vspace
      end

      error_indent(error, h + message)
    end

    def error_indent error, message
      a = message.split(newline)
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
      skip_internal = skip_internal && !full_backtrace?
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
