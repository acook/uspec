module Uspec
  module DSL
    module_function
    def spec description
      formatter = Uspec::Formatter.new

      print ' -- ', description

      return print(': ' + formatter.yellow('pending') + formatter.vspace) unless block_given?

      begin
        result = yield
      rescue => result
      end

      Uspec::Stats.results << result
      print ': ', formatter.colorize(result, caller), "\n"
    rescue => error
      message = <<-MSG
        Uspec encountered an internal error, please report this bug!
        https://github.com/acook/uspec/issues/new
        #{error.class} : #{error.message}
        #{error.backtrace.join "\n\t"}
      MSG
      puts
      warn message
      Uspec::Stats.results << [message, error]
    end
  end
end
