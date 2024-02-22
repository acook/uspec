require_relative "result"
require_relative "spec"

module Uspec
  class DSL

    def initialize cli
      @__uspec_cli = cli
    end

    def __uspec_cli
      @__uspec_cli
    end

    def __uspec_stats
      @__uspec_cli.stats
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

      if result.success?
        __uspec_stats.success << result
      elsif result.pending?
        __uspec_stats.pending << result
      else
        __uspec_stats.failure << result
      end

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
      __uspec_stats.failure << Uspec::Result.new(message, error, caller)
    ensure
      __uspec_cli.handle_interrupt! result.raw
      return [state, error, result, raw_result]
    end
  end
end
