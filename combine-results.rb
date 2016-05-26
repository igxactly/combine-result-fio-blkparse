#!/usr/bin/env ruby

require 'json'

#################
# main program flow starts here

# Signal.trap("PIPE", "EXIT")

puts "\n\n"

# read fio result
File.open(ARGV[0], "r") do |f|
    t = f.read()
    o = JSON.parse(t)
    #$fio_res = o

    # puts o

    $fio_res = {"clat" => Hash[*[["min", "max", "mean"], o["jobs"][0]["read"]["clat"].values_at("min", "max", "mean")].transpose.flatten], "slat" => Hash[*[["min", "max", "mean"], o["jobs"][0]["read"]["slat"].values_at("min", "max", "mean")].transpose.flatten]}
end

# read yabtar result
File.open(ARGV[1], "r") do |f|
    t = f.read()
    o = JSON.parse(t)
    $yabtar_res = o

    # puts o
end

$combined_res = {"fio_res"=>$fio_res, "yabtar_res"=>$yabtar_res}

# write breakdown result (in which format?)
File.open(ARGV[2], "w") do |f|
    t = JSON.generate($combined_res)
    f.write(t)

    puts t
end

puts "\n\n"


