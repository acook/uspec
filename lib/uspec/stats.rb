module Uspec
  class Stats
    def initialize
      clear_results!
    end
    attr :success, :failure, :pending

    def << result
      if result.success?
        self.success << result
      elsif result.pending?
        self.pending << result
      else
        self.failure << result
      end
    end

    def clear_results!
      @success = Array.new
      @failure = Array.new
      @pending = Array.new
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
