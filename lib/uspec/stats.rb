module Uspec
  class Stats
    def initialize
      clear_results!
    end
    attr :success, :failure, :pending

    def clear_results!
      @success = Array.new
      @failure = Array.new
      @pending = Array.new
    end

    def inspect
      <<-INFO
        #{super} Failures: #{@failure.size}
        #{results.map{|r| r.inspect}.join "\n\t" }
      INFO
    end

    def results
      @success + @failure + @pending
    end

    def summary
      [
        "test summary: ",
        Uspec::Terminal.green("#{@success.size} successful"),
        ", ",
        Uspec::Terminal.red("#{@failure.size} failed"),
        ", ",
        Uspec::Terminal.yellow("#{@pending.size} pending")
      ].join
    end
  end
end
