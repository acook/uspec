require_relative "result"
require_relative "spec"

module Uspec
  class Harness

    def initialize cli
      @cli = cli
      @define = Uspec::Define.new self
    end
    attr_accessor :cli, :define

    def stats
      cli.stats
    end

    def file_eval path
      define.instance_eval(path.read, path.to_s)
    rescue Exception => error
      if SignalException === error || SystemExit === error then
        exit 3
      end

      error_file, error_line, _ = error.backtrace.first.split ?:

      message = <<-MSG
        #{error.class} : #{error.message}

        Uspec encountered an error when loading a test file.
        This is probably a typo in the test file or the file it is testing.

        If you think this is a bug in Uspec please report it: https://github.com/acook/uspec/issues/new

        Error occured when loading test file `#{spec || path}`.
        The origin of the error may be in file `#{error_file}` on line ##{error_line}.

  \t#{error.backtrace[0,3].join "\n\t"}
      MSG
      puts
      warn message
      stats << Uspec::Result.new(message, error, true)

      cli.handle_interrupt! error
    end

    def spec_eval description, &block
      ex = nil
      state = 0
      print ' -- ', description

      if block then
        begin
          state = 1
          spec = Uspec::Spec.new(self, description, &block)
          raw_result = spec.__uspec_block
          state = 2
        rescue Exception => raw_result
          state = 3
          ex = true
        end
      end

      result = Uspec::Result.new spec, raw_result, ex

      unless block then
        state = 4
        result.pending!
      end

      stats << result

      print ': ', result.pretty, "\n"
    rescue => error
      state = 5
      message = <<-MSG
        #{error.class} : #{error.message}

        Uspec encountered an internal error, please report this bug: https://github.com/acook/uspec/issues/new

\t#{error.backtrace.join "\n\t"}
      MSG
      puts
      warn message
      stats << Uspec::Result.new(message, error, true)
    ensure
      cli.handle_interrupt! result.raw
      return [state, error, result, raw_result]
    end
  end
end
