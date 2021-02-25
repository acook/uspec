require_relative "result"

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

    def spec description
      print ' -- ', description

      if block_given? then
        begin
          raw_result = yield
        rescue Exception => raw_result
        end
      end

      result = Result.new description, raw_result, caller

      unless block_given? then
        result.pending!
      end

      if result.success?
        __uspec_stats.success << result
      elsif result.pending?
        stats.pending << result
      else
        __uspec_stats.failure << result
      end

      print ': ', result.pretty, "\n"
    rescue => error
      message = <<-MSG
        #{error.class} : #{error.message}

        Uspec encountered an internal error, please report this bug: https://github.com/acook/uspec/issues/new

\t#{error.backtrace.join "\n\t"}
      MSG
      puts
      warn message
      __uspec_stats.failure << Uspec::Result.new(message, error, caller)
    end
  end
end
