#!/usr/bin/env ruby

require 'json'

#################
# main program flow starts here

# Signal.trap("PIPE", "EXIT")

# read fio result
File.open(ARGV[0], "r") do |f|
    t = f.read()
    o = JSON.parse(t)

    $fio_res =
        {
            "R"=>
            {
                "clat" => Hash[*[["min", "max", "mean"], o["jobs"][0]["read"]["clat"].values_at("min", "max", "mean")].transpose.flatten],
                "slat" => Hash[*[["min", "max", "mean"], o["jobs"][0]["read"]["slat"].values_at("min", "max", "mean")].transpose.flatten]
            },
            "W"=>
            {
                "clat" => Hash[*[["min", "max", "mean"], o["jobs"][0]["write"]["clat"].values_at("min", "max", "mean")].transpose.flatten],
                "slat" => Hash[*[["min", "max", "mean"], o["jobs"][0]["write"]["slat"].values_at("min", "max", "mean")].transpose.flatten]
            }
    }

    $fio_jobname = o["jobs"][0]["jobname"]

    # jobs [ {read, write, ...} ]
    #
    # grand_total_sum_slat = 0
    # grand_total_sum_clat = 0
    # grand_total_ios = 0
    #
    # for job in jobs
    #         grand_total_sum_slat += job.read.total_ios * job.read.slat.mean
    #         grand_total_sum_clat += job.read.total_ios * job.read.clat.mean
    #         grand_total_ios += job.read.total_ios
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


# transpos yabtar result
$yabtar_res.keys.each do |key_0|
    trans = Hash.new

    p = $yabtar_res[key_0]

    p.keys.each do |key_1|
        c = p[key_1]
        c.keys.each do |key_2|
            if trans[key_2].nil?
                trans[key_2] = Hash.new
            end

            trans[key_2][key_1] = c[key_2]
        end
    end

    $yabtar_res[key_0] = trans
end

$combined_res = Hash.new

$fio_res.keys.each do |key0|
    $combined_res[key0] = $fio_res[key0].merge($yabtar_res[key0])
end

# write breakdown result (in which format?)
File.open(ARGV[2], "w") do |f|
    t = JSON.generate($combined_res)
    f.write(t)
end

final_res = Hash.new

final_res["jobname"] = $fio_jobname
final_res["r_user"] = $combined_res["R"]["slat"]["mean"] * 1000.to_f
final_res["r_kern_drv"] = $combined_res["R"]["DRV-Q"]["mean"]
final_res["r_dev"] = $combined_res["R"]["C-DRV"]["mean"]
final_res["r_kern_other"] = $combined_res["R"]["clat"]["mean"] * 1000.to_f - (final_res["r_kern_drv"] + final_res["r_dev"])
final_res["w_user"] = $combined_res["W"]["slat"]["mean"] * 1000.to_f
final_res["w_kern_drv"] = $combined_res["W"]["DRV-Q"]["mean"]
final_res["w_dev"] = $combined_res["W"]["C-DRV"]["mean"]
final_res["w_kern_other"] = $combined_res["W"]["clat"]["mean"] * 1000.to_f - (final_res["w_kern_drv"] + final_res["w_dev"])


# puts JSON.generate(final_res)
puts "%s, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f" % final_res.values_at("jobname", "r_user", "r_kern_other", "r_kern_drv", "r_dev", "w_user", "w_kern_other", "w_kern_drv", "w_dev")

