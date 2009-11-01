module Sankey
	class Reagent
    attr_reader :size, :source, :drain

    def initialize(size)
      @size = size
    end

    def source=(process)
      process.output.push self
      @source = process
    end

    def drain=(process)
      process.input.push self
      @drain = process
    end
	end
end
