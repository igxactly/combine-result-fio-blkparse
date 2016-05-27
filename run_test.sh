#!/usr/bin/env bash

# for all_test_cases
# do
#     run blktrace
#         run fio_script > result_fio.json
#     stop blktrace
#
#     blkparse -i nvme0n1 -d all.blktrace
#     yabtar all.blktrace > result_blktrace.json
#
#     result_fio.json + result_blktrace.json --> result_latency_breakdown.json
# done

# echo "$(date -Ins);${kernel};${n_bs};${n_qd};$(${single_test_script} ${testname} ${n_bs}k ${n_qd} ${n_runt} ${format} ${n_jobs} | sed 's/[0-9]\+\.[0-9]\{6\}%=\([0-9]\+;\)/\1/g')" | tee result_${date}_${testname}_${i}.csv;

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

single_test_script=~/fio_presets/do_test_read.sh

dev=/dev/nvme0n1
n_runt=10;
n_jobs=1; #8;
format="json";
kernel=$(uname -r | sed 's/\([0-9]\.[0-9]\+\).\+/\1/g');
date=$(date -I)
trace_arg="-a queue -a drv_data -a complete"

for i in $(seq 1);
do

for n_bs in 4 128; # for each block size
do
    for n_qd in 1 1024; # for each queue depth
    do
        testname="${kernel}_job${n_jobs}_bs${n_bs}k_qd${n_qd}";
        mkdir -p ${testname}; cd ${testname};

        ### start trace
        echo "starting blktrace/fio..."
        sleep 3; blktrace ${trace_arg} ${dev} & PID_BLKTRACE=$!;

        ${single_test_script} ${testname} ${n_bs}k ${n_qd} ${n_runt} ${format} ${n_jobs} > fio_result.json; sync;

        sleep 3; kill ${PID_BLKTRACE}; fg; sync;
        echo "blktrace/fio done";
        ### end trace

        # parse and analyze block trace
        echo "parsing results...";
        blkparse -O -i nvme0n1 -d all.blktrace; sync;
        yabtar.rb all.blktrace yabtar_result.json | tail; sync;

        # final result
        combine-results.rb fio_result.json yabtar_result.json breakdown.json > breakdown.csv; sync;
        echo "parsing and anylysis done"
        cd ..;
    done;
done;
done;
