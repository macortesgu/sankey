require 'renderers/renderer'
require 'rvg/rvg'
require 'imagedata'

module Sankey::Renderers
  class RVG
    include Renderer
    include Sankey

    def initialize(data, filename, args = {})
      throw "data isn't ImageData" unless data.is_a? ImageData
      @grid = args[:grid] || false
      @vertices = data.vertices
      @filename = filename
      @width = args[:width] || data.width
      @height = args[:height] || data.height
      @width_ratio = 1.0 * @width / data.width
      @height_ratio = 1.0 * @height / data.height
    end

    def render
      canvas = Magick::ImageList.new
      canvas.new_image(@width, @height)
      draw_grid canvas if @grid
      @vertices.each { |v| draw_vertex canvas, v }
      canvas.write @filename
    end

  private

    def draw_grid(canvas)
      grid = Magick::Draw.new
      grid.stroke = 'lightgray'
      grid.stroke_width = 1
      0.upto @width/@grid do |x|
        grid.line x*@grid+@grid-1, 0, x*@grid+@grid-1, @height
      end
      0.upto @height/@grid do |x|
        grid.line 0, x*@grid+@grid-1, @width, x*@grid+@grid-1
      end
      grid.draw canvas
    end

    def draw_vertex(canvas, v)
      vertex = Magick::Draw.new
      vertex.stroke = 'black'
      vertex.stroke_width = 2
      first_x = prev_x = v.points.first.x * @width_ratio
      first_y = prev_y = v.points.first.y * @height_ratio
      v.points.each do |p|
        vertex.line prev_x, prev_y, p.x * @width_ratio, p.y * @height_ratio
        prev_x = p.x * @width_ratio
        prev_y = p.y * @height_ratio
      end
      vertex.line prev_x, prev_y, first_x, first_y
      vertex.draw canvas
    end
  end
end
