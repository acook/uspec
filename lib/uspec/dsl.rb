require_relative "result"

module Uspec
  module DSL
    module_function
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
        Uspec::CLI.stats.success << result
      elsif result.pending?
        Uspec::CLI.stats.pending << result
      else
        Uspec::CLI.stats.failure << result
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
      Uspec::Stats.failure << Uspec::Result.new(message, error, caller)
    end
  end
end
