#!/usr/bin/ruby -Ilib
require 'sankey'
require 'renderers/rvg'

g = Sankey::Generator.new
beans = Sankey::Reagent.new 100
ground_coffee = Sankey::Reagent.new 200
water = Sankey::Reagent.new 50
beverage = Sankey::Reagent.new 300
crema = Sankey::Reagent.new 50
espresso_machine = Sankey::Process.new
grinder = Sankey::Process.new
beans.drain = grinder
water.drain = espresso_machine
ground_coffee.drain = espresso_machine
ground_coffee.source = grinder
beverage.source = espresso_machine
crema.source = espresso_machine
g.processes.push espresso_machine
g.processes.push grinder
g.go!
p = Sankey::Renderers::RVG.new g.data, "espresso.png"
p.render