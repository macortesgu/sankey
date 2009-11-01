module Sankey
	class Process
    attr_reader :input, :output

    def initialize
      @input = []
      @output = []
    end

    def fraction(reagent)
      side = nil
      [@output, @input].each { |io| side = io if io.include? reagent }
      throw "Reagent isn't present in this process" if side.nil?
      sum = 0
      side.each { |r| sum += r.size }
      reagent.size * 1.0 / sum
    end
	end
end
