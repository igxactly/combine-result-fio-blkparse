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

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# if [[ "$#" < 2 ]] && [ "$#" > 2 ]  ; then
#     echo "!!! usage: $0 testTitle blockSize queueDepth (runTime outFormat numJobs) #():optional";
#     exit 0;
# fi;

if [ "${1}" == "normal" ]; then
    single_test_script=~/fio_presets/do_test_normalWorkload.sh;
elif [ "${1}" == "low4k" ]; then
    single_test_script=~/fio_presets/do_test_lowWorkload4k.sh;
elif [ "${1}" == "low64k" ]; then
    single_test_script=~/fio_presets/do_test_lowWorkload64k.sh;
else
    echo "select preset: normal low4k low64k";
    exit 1;
fi;

dev=/dev/nvme0n1
kernel=$(uname -r | sed 's/\([0-9]\.[0-9]\+\).\+/\1/g');
trace_arg="-a queue -a drv_data -a complete"

for i in $(seq 1);
do

    testname="${kernel}_${1}_test${i}";
    mkdir -p ${testname}; cd ${testname};

    ### start trace
    echo "starting blktrace/fio..."
    sleep 3; blktrace ${trace_arg} ${dev} & PID_BLKTRACE=$!;

    # log cpu load
    while true; do echo $(date -Ins) $(cat /proc/stat | egrep "(cpu |ctx)"); sleep 0.25; done > cpuload.log & PID_CPULOGGER=$!;

    # run fio test
    ${single_test_script} ${testname} > fio_result.json; kill ${PID_CPULOGGER}; sync;

    # stop trace
    sleep 3; kill ${PID_BLKTRACE}; sync;
    echo "blktrace/fio done";
    ### end of trace

    # parse and analyze block trace log
    echo "parsing results...";
    blkparse -O ${trace_arg} -i nvme0n1 -d all.blktrace; sync;
    yabtar.rb all.blktrace yabtar_result.json | tail -n 25; sync;

    # final result
    combine-results.rb fio_result.json yabtar_result.json breakdown.json > breakdown.csv; sync;
    echo "parsing and anylysis done"
    cd ..;

done;
