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

    def __uspec_eval block
      asm = RubyVM::InstructionSequence.disasm(block)

      if asm =~ /^\d+ throw +1$/ then
        raise LocalJumpError, "Invalid return in spec block."
      elsif asm =~ /^\d+ throw +2$/ then
        raise LocalJumpError, "Invalid break in spec block."
      else
        block.call
      end
    end

    def spec description, &block
      state = 0
      print ' -- ', description

      if block then
        begin
          state = 1
          raw_result = __uspec_eval block
          state = 3
        rescue Exception => raw_result
          state = 4
        end
      end

      result = Result.new description, raw_result, caller

      unless block then
        state = 5
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
      state = 6
      message = <<-MSG
        #{error.class} : #{error.message}

        Uspec encountered an internal error, please report this bug: https://github.com/acook/uspec/issues/new

\t#{error.backtrace.join "\n\t"}
      MSG
      puts
      warn message
      __uspec_stats.failure << Uspec::Result.new(message, error, caller)
    ensure
      return [state, error, result, raw_result]
    end
  end
end
