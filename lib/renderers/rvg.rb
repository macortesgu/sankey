require 'renderers/renderer'
require 'rvg/rvg'
require 'imagedata'

module Sankey::Renderers
  class RVG
    include Renderer
    include Sankey

    Magick::RVG::dpi = 100

    def initialize(data, filename)
      throw "data isn't ImageData" unless data.is_a? ImageData
      @vertices = data.vertices
      @width = data.width
      @height = data.height
      @filename = filename
    end

    def render
      rvg = Magick::RVG.new(2.in, 2.in).viewbox(0,0,@width,@height) do |canvas|
        canvas.background_fill = 'white'
        canvas.styles :stroke => 'black', :stroke_width => 2, :fill => 'white'
        @vertices.each { |v| draw canvas, v }
      end
      rvg.draw.write @filename
    end

  private

    def draw(c, v)
      arr = []
      v.points.each do |p|
        arr.push p.x
        arr.push p.y
      end
      arr.push v.points.first.x
      arr.push v.points.first.y
      c.polyline arr
    end
  end
end
