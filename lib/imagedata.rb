module Sankey
  class ImageData
    attr_reader :vertices, :width, :height

    def initialize(vertices, width, height)
      @vertices = vertices
      @width = width
      @height = height
    end
  end
end
