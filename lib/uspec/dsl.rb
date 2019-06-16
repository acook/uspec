require_relative "result"

module Uspec
  module DSL
    module_function
    def spec description
      terminal = Uspec::Terminal

      print ' -- ', description

      return print(': ' + terminal.yellow('pending') + terminal.vspace) unless block_given?

      begin
        raw_result = yield
      rescue => raw_result
      end

      result = Result.new description, raw_result, caller

      Uspec::Stats.results << result

      print ': ', result.pretty, "\n"
    rescue => error
      message = <<-MSG
        Uspec encountered an internal error, please report this bug!
        https://github.com/acook/uspec/issues/new
        #{error.class} : #{error.message}
        #{error.backtrace.join "\n\t"}
      MSG
      puts
      warn message
      Uspec::Stats.results << Result.new(message, error, caller)
    end
  end
end
