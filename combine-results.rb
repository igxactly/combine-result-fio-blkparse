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

    $fio_res = {"clat" => Hash[*[["min", "max", "mean"], o["jobs"][0]["read"]["clat"].values_at("min", "max", "mean")].transpose.flatten], "slat" => Hash[*[["min", "max", "mean"], o["jobs"][0]["read"]["slat"].values_at("min", "max", "mean")].transpose.flatten]}

# jobs [ {read, write, ...} ]
#
# grand_total_sum_slat = 0
# grand_total_sum_clat = 0
# grand_total_ios = 0
#
# for job in jobs
#         grand_total_sum_slat += job.read.total_ios * job.read.slat.mean
#             grand_total_sum_clat += job.read.total_ios * job.read.clat.mean
#                 grand_total_ios += job.read.total_ios
# end
#
# grand_avg_slat = grand_total_sum_slat.to_f / grand_total_ios
# grand_avg_clat = grand_total_sum_clat.to_f / grand_total_ios

end

# read yabtar result
File.open(ARGV[1], "r") do |f|
    t = f.read()
    o = JSON.parse(t)
    $yabtar_res = o
end

$combined_res = {"fio_res"=>$fio_res, "yabtar_res"=>$yabtar_res}

# write breakdown result (in which format?)
File.open(ARGV[2], "w") do |f|
    t = JSON.generate($combined_res)
    f.write(t)

    puts t
end

puts "\n\n"

