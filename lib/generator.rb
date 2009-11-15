require 'processvertex'
require 'point'
require 'imagedata'

module Sankey
  class Generator
    attr_reader :processes, :data

    ProcessWidth = 40
    ProcessLayerStep = 100
    ProcessSideStep = 50
    Margin = 5
    InputReagentsStep = 20
    OutputReagentsStep = 20

    def initialize
      @processes = []
    end

    def go!
      @processes_vertices = {}
      @drawn_reagents = []
      @vertices = []
      @input_reagent_offset = Margin
      @output_reagent_offset = 0
      @process_input_offset = {}
      @process_output_offset = {}
      get_max_distances_to_processes
      to_be_drawn = []
      input_reagents.each { |r| to_be_drawn.push r }
      until to_be_drawn.empty? do
        STDERR.puts "to draw"
        to_be_drawn.each { |r| STDERR.puts "  " + r.to_s + " " + r.name }
        not_drawn = []
        to_be_drawn.each { |r| not_drawn += recursively_draw r }
        to_be_drawn = not_drawn.uniq
      end
      w, h = get_size
      @data = ImageData.new @vertices, w, h
    end

    private

    def get_max_distances_to_processes(reagent = nil, level = 0)
      if reagent.nil?
        @max_distances_to_processes = {}
        input_reagents.each { |r| get_max_distances_to_processes r }
      elsif !reagent.drain.nil?
        new_level = level + 1
        if @max_distances_to_processes[reagent.drain].nil? or
          @max_distances_to_processes[reagent.drain] < new_level
          @max_distances_to_processes[reagent.drain] = new_level
        end
        reagent.drain.output.each do |r|
          get_max_distances_to_processes r, new_level
        end
      end
    end

    def draw_process(process)
      layer = @max_distances_to_processes[process] - 1
      height = process.total_reagents_mass
      corner = Point.new (layer+1)*(ProcessLayerStep+ProcessWidth) + Margin,
        Margin
      v = ProcessVertex.new corner, corner + [0, height],
        corner + [ProcessWidth, height], corner + [ProcessWidth, 0]
      @vertices.push v
      @processes_vertices[process] = v
    end

    def recursively_draw(reagent)
      return [] if @drawn_reagents.include? reagent
      STDERR.puts "    drawing " + reagent.name if reagent.name != ""
      if reagent.drain.nil?
        if reagent.source.is_first_in_output_queue reagent
          draw_output_reagent reagent
          reagent.source.remove_from_output_queue reagent
        else
          STDERR.puts "      later"
          return [reagent]
        end
      elsif reagent.source.nil?
        if reagent.drain.is_first_in_input_queue reagent
          draw_input_reagent reagent
          reagent.drain.remove_from_input_queue reagent
        else
          STDERR.puts "      later"
          return [reagent]
        end
      else
        if reagent.drain.is_first_in_input_queue(reagent) and
            reagent.source.is_first_in_output_queue(reagent)
          draw_middle_reagent reagent
          reagent.source.remove_from_output_queue reagent
          reagent.drain.remove_from_input_queue reagent
        else
          #STDERR.puts reagent.drain.is_first_in_input_queue(reagent)
          #STDERR.puts reagent.source.is_first_in_output_queue(reagent)
          STDERR.puts "      later"
          return [reagent]
        end
      end
      @drawn_reagents.push reagent
      to_draw_later = []
      unless reagent.drain.nil?
        reagent.drain.output.each { |r| to_draw_later += recursively_draw r }
      end
      to_draw_later
    end

    def draw_middle_reagent(reagent)
      left_height = reagent.source.total_reagents_mass *
        reagent.source.fraction(reagent)
      right_height = reagent.drain.total_reagents_mass *
        reagent.drain.fraction(reagent)
      [reagent.source, reagent.drain].each do |p|
        draw_process p unless @processes_vertices.include? p
      end
      @process_input_offset[reagent.drain] ||= 0
      @process_output_offset[reagent.source] ||= 0
      left_corner = @processes_vertices[reagent.source].output_edge[:top] +
        [0, @process_output_offset[reagent.source]]
      right_corner = @processes_vertices[reagent.drain].input_edge[:top] +
        [0, @process_input_offset[reagent.drain]]
      v = Vertex.new
      v.points.push left_corner
      v.points.push left_corner + [0, left_height]
      v.points.push right_corner + [0, right_height]
      v.points.push right_corner
      @vertices.push v
      @process_input_offset[reagent.drain] += right_height
      @process_output_offset[reagent.source] += left_height
    end

    def draw_input_reagent(reagent)
      draw_process reagent.drain unless @processes_vertices.include? reagent.drain
      height = reagent.drain.total_reagents_mass * reagent.drain.fraction(reagent)
      left_corner = Point.new Margin, @input_reagent_offset
      v = Vertex.new
      v.points.push left_corner
      v.points.push left_corner + [5, height / 2]
      v.points.push left_corner + [0, height]
      @process_input_offset[reagent.drain] ||= 0
      v.points.push @processes_vertices[reagent.drain].input_edge[:top] +
        [0, @process_input_offset[reagent.drain] + height]
      v.points.push @processes_vertices[reagent.drain].input_edge[:top] +
        [0, @process_input_offset[reagent.drain]]
      @vertices.push v
      @input_reagent_offset += height + InputReagentsStep
      @process_input_offset[reagent.drain] += height
    end

    def draw_output_reagent(reagent)
      height = reagent.source.total_reagents_mass *
        reagent.source.fraction(reagent)
      @process_output_offset[reagent.source] ||= 0
      left_corner = @processes_vertices[reagent.source].output_edge[:top] +
        [0, @process_output_offset[reagent.source]]
      v = Vertex.new
      v.points.push left_corner
      v.points.push left_corner + [0, height]
      v.points.push left_corner +
        [ProcessLayerStep, @output_reagent_offset + height]
      v.points.push left_corner +
        [ProcessLayerStep + 5, @output_reagent_offset + height / 2]
      v.points.push left_corner +
        [ProcessLayerStep, @output_reagent_offset]
      @vertices.push v
      @process_output_offset[reagent.source] += height
      @output_reagent_offset += OutputReagentsStep
    end

    def input_reagents
      return @input_reagents if defined? @input_reagents
      @input_reagents = []
      @processes.each do |process|
        process.input.each do |reagent|
          @input_reagents.push reagent if reagent.source.nil?
        end
      end
      @input_reagents.uniq!
      @input_reagents
    end

    def get_size
      w = h = 0
      @vertices.each do |vertex|
        vertex.points.each do |point|
          w = point.x + Margin if point.x + Margin > w
          h = point.y + Margin if point.y + Margin > h
        end
      end
      return w, h
    end
  end
end
