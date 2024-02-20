require_relative "result"

module Uspec
  class DSL
    USPEC_CLI_BLOCK = -> { @__uspec_dsl.__uspec_cli }
    USPEC_STAT_BLOCK = -> { @__uspec_dsl.__uspec_cli.stats }
    USPEC_SPEC_BLOCK = ->(description, &block) { @__uspec_dsl.spec description, &block }

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
      o = Object.new
      o.define_singleton_method :__uspec_stats, USPEC_STAT_BLOCK
      o.define_singleton_method :__uspec_cli, USPEC_CLI_BLOCK
      o.instance_variable_set :@__uspec_cli, @__uspec_cli
      o.instance_variable_set :@__uspec_dsl, self
      o.define_singleton_method :spec, USPEC_SPEC_BLOCK
      o.define_singleton_method :spec_block, &block
      self.instance_variables.each do |name|
        o.instance_variable_set(name, self.instance_variable_get(name)) unless name.to_s.include? '@__uspec'
      end
      self.methods(false).each do |name|
        o.define_singleton_method name do |*args, &block|
          @__uspec_dsl.send name, *args, &block
        end unless name.to_s.include? '__uspec'
      end
      o.spec_block
    end

    def spec description, &block
      state = 0
      print ' -- ', description

      if block then
        begin
          state = 1
          raw_result = __uspec_eval block
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
      return [state, error, result, raw_result]
    end
  end
end
