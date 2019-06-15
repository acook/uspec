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
        failures = results.count{|result| result != true }
        failures > 255 ? 255 : failures
      end
    end
  end
end
