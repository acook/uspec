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
        results.all?{|result| result == true} ? 0 : 255
      end
    end
  end
end
