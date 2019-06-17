require_relative "result"

module Uspec
  module DSL
    module_function
    def spec description
      terminal = Uspec::Terminal

      print ' -- ', description

      return print(': ' + terminal.yellow('pending') + terminal.newline) unless block_given?

      begin
        raw_result = yield
      rescue => raw_result
      end

      result = Result.new description, raw_result, caller

      Uspec::Stats.results << result

      print ': ', result.pretty, "\n"
    rescue => error
      message = <<-MSG
        #{error.class} : #{error.message}

        Uspec encountered an internal error, please report this bug: https://github.com/acook/uspec/issues/new

        #{error.backtrace.join "\n\t"}
      MSG
      puts
      warn message
      Uspec::Stats.results << Uspec::Result.new(message, error, caller)
    end
  end
end
