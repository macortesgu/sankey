module Sankey
	class Reagent
    attr_reader :size, :source, :drain, :name

    def initialize(size, name = '')
      @size = size
      @name = name
    end

    def source=(process)
      process.add_output self
      @source = process
    end

    def drain=(process)
      process.add_input self
      @drain = process
    end

    def add_drain(process, order = nil)
      process.add_input self, order
      @drain = process
    end

    def add_source(process, order = nil)
      process.add_output self, order
      @source= process
    end
	end
end
