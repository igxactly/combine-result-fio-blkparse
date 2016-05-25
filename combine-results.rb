#!/usr/bin/env ruby

require 'json'

#################
# main program flow starts here

Signal.trap("PIPE", "EXIT")

puts "\n\n"

# read fio result
File.open(ARGV[0], "r") do |f|
    t = f.read()
    o = JSON.parse(t)

    puts o
end

# read yabtar result
File.open(ARGV[1], "r") do |f|
    t = f.read()
    o = JSON.parse(t)

    puts o
end

# write breakdown result (in which format?)
File.open(ARGV[2], "w") do |outfile|
    outfile.write(JSON.generate(o))
end

puts "\n\n"


