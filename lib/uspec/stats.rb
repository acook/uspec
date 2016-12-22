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
        failures = results.count{|result| !result }
        failures > 255 ? 255 : failures
      end
    end
  end
end
