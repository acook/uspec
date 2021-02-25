module Uspec
  class Stats
    def initialize
      clear_results!
    end
    attr :success, :failure, :pending, :special

    def clear_results!
      @success = Array.new
      @failure = Array.new
      @pending = Array.new
      @special = Array.new
    end

    def inspect
      <<-INFO
        #{super} Failures: #{exit_code}
        #{results.map{|r| r.inspect}.join "\n\t" }
      INFO
    end

    def results
      @success + @failure + @pending
    end
  end
end
