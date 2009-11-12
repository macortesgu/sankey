module Sankey
  class Process
    attr_reader :input, :output

    def initialize
      @input = []
      @output = []
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
