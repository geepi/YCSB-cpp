#!/bin/bash

recordcount=100000000
operationcount=100000000
output_path=/data/public/jyj/output/others/zipfian
cgroup_path=/sys/fs/cgroup/memory/palm

# limit memory
memory_limit=1G
mkdir -p $output_path
if [ ! -d cgroup_path ] ;then
    sudo cgcreate -t jyj:jyj -a jyj:jyj -g memory:palm
fi
echo "$memory_limit" > $cgroup_path/memory.limit_in_bytes

# make
# make BIND_ROCKSDB=1 -ldl -lz -lsnappy -lzstd -lbz2 -llz4 BIND_HDRHISTOGRAM=1 \
# EXTRA_CXXFLAGS=-I/data/public/jyj/rocksdb/include EXTRA_LDFLAGS="-L/data/public/jyj/rocksdb/build"
# mv ./ycsb ./ycsb_rocksdb

make BIND_WIREDTIGER=1 -lsnappy BIND_HDRHISTOGRAM=1
mv ./ycsb ./ycsb_wiredtiger

# make BIND_LMDB=1 BIND_HDRHISTOGRAM=1
# mv ./ycsb ./ycsb_lmdb

for db_name in wiredtiger;do
    rm -rf /tmp/ycsb-${db_name}
    log_path=$output_path/${db_name}
    mkdir -p $log_path
    log=$log_path/${db_name}

    echo "memory_limit: $memory_limit" >> ${log}.txt

    ./ycsb_${db_name} -load -db ${db_name} -P workloads/workloada -P ${db_name}/${db_name}.properties \
        -p recordcount=$recordcount -p operationcount=$operationcount -s |tee -a ${log}.txt &
    pid=$(pgrep ycsb)
    echo $pid >> $cgroup_path/cgroup.procs

    sudo iotop -b -o -p $pid -d 10 -k -q >> ${log}_load_bw.txt &
    wait $pid
    sudo kill -9 $(pgrep iotop)

    for type in a b c d;do
        ./ycsb_${db_name} -run -db ${db_name} -P workloads/workload${type} -P ${db_name}/${db_name}.properties \
            -p recordcount=$recordcount -p operationcount=$operationcount -s |tee -a ${log}.txt &
        pid=$(pgrep ycsb)
        echo $pid >> $cgroup_path/cgroup.procs

        sudo iotop -b -o -p $pid -d 10 -k -q >> ${log}_${type}_bw.txt &
        wait $pid
        sudo kill -9 $(pgrep iotop)
    done
done