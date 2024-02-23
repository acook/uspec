require_relative "result"
require_relative "spec"

module Uspec
  class Harness

    def initialize cli
      @cli = cli
      @define = ::Uspec::Define.new self
    end
    attr_accessor :cli, :define

    def stats
      cli.stats
    end

    def spec description, &block
      state = 0
      print ' -- ', description

      if block then
        begin
          state = 1
          raw_result = ::Uspec::Spec.new(self, description, &block).__uspec_block
          state = 2
        rescue Exception => raw_result
          state = 3
        end
      end

      result = Result.new description, raw_result, caller

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
      stats << Uspec::Result.new(message, error, caller)
    ensure
      cli.handle_interrupt! result.raw
      return [state, error, result, raw_result]
    end
  end
end
