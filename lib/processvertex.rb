require 'vertex'

module Sankey
  class ProcessVertex < Vertex
    def initialize(a, b, c, d)
      super()
      [a, b, c, d].each { |x| @points.push x }
    end

    def input_edge
      {:bottom => @points[1], :top => @points[0]}
    end

    def output_edge
      {:bottom => @points[2], :top => @points[3]}
    end
	end
end
