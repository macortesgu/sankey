module Sankey
  class Process
    attr_reader :input, :output

    def initialize
      @input = []
      @output = []
      @input_reagents_queue = {}
      @output_reagents_queue = {}
    end

    def fraction(reagent)
      side = nil
      [@output, @input].each { |io| side = io if io.include? reagent }
      throw "Reagent isn't present in this process" if side.nil?
      sum = 0
      side.each { |r| sum += r.size }
      reagent.size * 1.0 / sum
    end

    def total_reagents_mass
      check_conservation_of_mass
    end

    def add_output(reagent, order = nil)
      @output.push reagent
      @output_reagents_queue[order] = reagent unless order.nil?
    end

    def add_input(reagent, order = nil)
      @input.push reagent
      @input_reagents_queue[order] = reagent unless order.nil?
    end

    def remove_from_input_queue(reagent)
      key_to_be_removed = nil
      @input_reagents_queue.each do |key, val|
        key_to_be_removed = key if val == reagent
      end
      @input_reagents_queue.delete key_to_be_removed
    end

    def remove_from_output_queue(reagent)
      key_to_be_removed = nil
      @output_reagents_queue.each do |key, val|
        key_to_be_removed = key if val == reagent
      end
      @output_reagents_queue.delete key_to_be_removed
    end

    def is_first_in_input_queue(reagent)
      min_key = nil
      return true unless @input_reagents_queue.values.include? reagent
      @input_reagents_queue.each do |key, val|
        #STDERR.puts "#{key} -> #{val.name}"
        min_key ||= key
        min_key = [min_key, key].min
      end
      @input_reagents_queue[min_key] == reagent
    end

    def is_first_in_output_queue(reagent)
      min_key = nil
      return true unless @output_reagents_queue.values.include? reagent
      @output_reagents_queue.each do |key, val|
        min_key ||= key
        min_key = [min_key, key].min
      end
      @output_reagents_queue[min_key] == reagent
    end

  private

    def check_conservation_of_mass
      input_sum = output_sum = 0
      @input.each { |r| input_sum += r.size }
      @output.each { |r| output_sum += r.size }
      throw 'Conservation of mass constraint failed: ' +
        "#{input_sum} != #{output_sum}" if input_sum != output_sum
      input_sum
    end
  end
end
