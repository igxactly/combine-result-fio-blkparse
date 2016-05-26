#!/usr/bin/env ruby

require 'json'

#################
# main program flow starts here

# Signal.trap("PIPE", "EXIT")

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

=begin
trans_fio_res = Hash.new

$fio_res.keys.each do |key_1|
    h = $fio_res[key_1]

    h.keys.each do |key_2|
        if trans_fio_res[key_2].nil?
            trans_fio_res[key_2] = Hash.new
        end

        trans_fio_res[key_2][key_1] = h[key_2]
    end
end
$fio_res = trans_fio_res
=end

trans_fio_res = Hash.new

$yabtar_res.keys.each do |key_1|
    h = $yabtar_res[key_1]

    h.keys.each do |key_2|
        if trans_fio_res[key_2].nil?
            trans_fio_res[key_2] = Hash.new
        end

        trans_fio_res[key_2][key_1] = h[key_2]
    end
end
$yabtar_res = trans_fio_res

$combined_res = $fio_res.merge($yabtar_res)

# write breakdown result (in which format?)
File.open(ARGV[2], "w") do |f|
    t = JSON.generate($combined_res)
    f.write(t)
end

final_res = Hash.new

final_res["user"] = $combined_res["slat"]["mean"] * 1000.to_f
final_res["kern_drv"] = $combined_res["DRV-Q"]["mean"]
final_res["dev"] = $combined_res["C-DRV"]["mean"]
final_res["kern_other"] = $combined_res["clat"]["mean"] * 1000.to_f - (final_res["kern_drv"] + final_res["dev"])

# puts JSON.generate(final_res)

puts "%.4f, %.4f, %.4f, %.4f" % final_res.values_at("user", "kern_other", "kern_drv", "dev") 
