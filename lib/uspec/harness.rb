require_relative "result"
require_relative "spec"

module Uspec
  class Harness

    def initialize cli
      @cli = cli
      @define = Uspec::Define.new self
    end
    attr_accessor :cli, :define

    def stats
      cli.stats
    end

    def file_eval path, line
      @path = path
      @line = line
      define.instance_eval(path.read, path.to_s)
    rescue Exception => error
      raise error if SystemExit === error
      result = Uspec::Errors.handle_file_error error, path, cli
      stats << result if result
    end

    def spec_eval description, source, &block
      return if @line && !source.first.include?("#{@path}:#{@line}")

      ex = nil
      state = 0
      print ' -- ', description

      if block then
        begin
          state = 1
          spec = Uspec::Spec.new(self, description, &block)
          raw_result = spec.__uspec_block
          state = 2
        rescue Exception => raw_result
          state = 3
          ex = true
        end
      end

      result = Uspec::Result.new spec, raw_result, ex

      unless block then
        state = 4
        result.pending!
      end

      print ': ', result.pretty, "\n"
    rescue => error
      result = Uspec::Errors.handle_internal_error error, cli
    ensure
      stats << result if result
      cli.handle_interrupt! result ? result.raw : raw_result
      return [state, error, result, raw_result]
    end
  end
end
