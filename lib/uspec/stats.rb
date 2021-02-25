module Uspec
  class Stats
    class << self
      def results?
        !results.empty?
      end

      def results
        @results || clear_results!
      end

      def clear_results!
        @pending = Array.new
        @results = Array.new
      end

      def exit_code
        failures > 255 ? 255 : failures
      end

      def failures
        results.count{|result| result.raw != true }
      end

      def successes
        # checking for truthy isn't good enough, it must be exactly true!
        results.count{|result| result.raw == true }
      end

      def pending
        @pending || clear_results!
      end

      def inspect
        <<-INFO
        #{super} Failures: #{exit_code}
        #{results.map{|r| r.inspect}.join "\n\t" }
        INFO
      end

      def summary
        [
          "test summary: ",
          Uspec::Terminal.green("#{Uspec::Stats.successes} successful"),
          ", ",
          Uspec::Terminal.red("#{Uspec::Stats.failures} failed"),
          ", ",
          Uspec::Terminal.yellow("#{Uspec::Stats.pending.size} pending")
        ].join
      end
    end
  end
end
