module Sankey
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def +(val)
      if val.is_a? Array and 2 == val.length
        x = val[0]
        y = val[1]
      else
        throw "Invalid argument"
      end
      Point.new @x + x, @y + y
    end
	end
end
