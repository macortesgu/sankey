require 'renderers/renderer'
require 'rvg/rvg'
require 'imagedata'

module Sankey::Renderers
  class RVG
    include Renderer
    include Sankey

    def initialize(data, filename = nil, args = {})
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
      if @filename.nil?
        return canvas.to_blob { self.format = 'PNG' }
      else
        canvas.write @filename
      end
    end

  private

    def draw_grid(canvas)
      grid = Magick::Draw.new
      grid.stroke = 'lightgray'
      grid.stroke_width = 1
      0.upto @width/@grid/@width_ratio do |x|
        grid.line @width_ratio*(x*@grid+@grid-1), 0,
          (x*@grid+@grid-1)*@width_ratio, @height
      end
      0.upto @height/@grid/@height_ratio do |x|
        grid.line 0, (x*@grid+@grid-1)*@height_ratio, @width,
          (x*@grid+@grid-1)*@height_ratio
      end
      grid.draw canvas
    end

    def draw_vertex(canvas, v)
      vertex = Magick::Draw.new
      vertex.stroke = 'black'
      vertex.stroke_width = 1
      vertex.fill = 'lightgray'
      coords = v.points.map { |p| [p.x * @width_ratio, p.y * @height_ratio] }
      vertex.polygon *coords.flatten
      vertex.draw canvas
    end
  end
end
