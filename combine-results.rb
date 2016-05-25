#!/usr/bin/env ruby

require 'json'

#################
# main program flow starts here

Signal.trap("PIPE", "EXIT")

puts "\n\n"

File.open(ARGV[0], "r") do |f|
    t = f.read()
    o = JSON.parse(t)

    puts o

    File.open(ARGV[1], "w") do |outfile|
       outfile.write(JSON.generate(o))
    end
end

puts "\n\n"


