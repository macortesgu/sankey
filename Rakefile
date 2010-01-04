# encoding: utf-8
require 'rake'

desc "Run rdoc"
task :rdoc do
  print `rdoc -a -S -N -w 2 -U -o doc/rdoc README.rdoc lib`
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'sankey'
    gemspec.summary = 'Sankey diagrams generator'
    gemspec.description = 'A small tool which generates Sankey diagrams.'
    gemspec.email = 'jstepien@users.sourceforge.net'
    gemspec.homepage = "http://github.com/jstepien/sankey"
    gemspec.authors = ['Jan Stępień']
    gemspec.files.exclude '.gitignore'
    gemspec.add_dependency 'rmagick'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
