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

    def __uspec_format
      @__uspec_cli.format
    end

    def spec description, tags = []
      format = __uspec_format

      print format.test_prefix
      print format.test description, tags
      print format.test_suffix

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
        __uspec_stats.pending << result
      else
        __uspec_stats.failure << result
      end

      print format.result_prefix
      print format.result result
      print format.result_suffix
    rescue => error
      message = format.internal_error error, <<-MSG
        Uspec encountered an internal error, please report this bug: https://github.com/acook/uspec/issues/new
      MSG
      warn
      warn message
      __uspec_stats.failure << Uspec::Result.new(message, error, caller)
    end
  end
end
