module Uspec
  class Stats
    class << self
      def results?
        !results.empty?
      end

      def results
        @results ||= clear_results!
      end

      def clear_results!
        @results = Array.new
      end

      def exit_code
        # checking for truthy isn't good enough, it must be exactly true!
        failures = results.count{|result| result.raw != true }
        failures > 255 ? 255 : failures
      end

      def inspect
        <<-INFO
        #{super} Failures: #{exit_code}
        #{results.map{|r| r.inspect}.join "\n\t" }
        INFO
      end
    end
  end
end
