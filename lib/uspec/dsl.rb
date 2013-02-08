module Uspec
  module DSL
    def spec description
      formatter = Uspec::Formatter.new

      print ' -- ', description

      return puts(': ' + formatter.yellow('pending') + formatter.vspace) unless block_given?

      begin
        result = yield
      rescue => result
      end

      print ': ', formatter.colorize(result, caller), "\n"
    end
  end
end
