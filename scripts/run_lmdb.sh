#!/bin/bash

#!/bin/bash

recordcount=10000000
operationcount=10000000
log_path=output
# log_path=/data/public/jyj/output/$(date +%F)
cgroup_path=/sys/fs/cgroup/memory/palm

memory_limit=150M

mkdir -p $log_path
if [ ! -d cgroup_path ] ;then
    sudo cgcreate -t jyj:jyj -a jyj:jyj -g memory:palm
fi
echo "$memory_limit" > $cgroup_path/memory.limit_in_bytes

for db_name in lmdb;do
    rm -rf /tmp/ycsb-${db_name}
    log=$log_path/${db_name}_$(date +%F).txt
    echo "memory_limit: $memory_limit" >> $log

    ./ycsb_lmdb -load -db ${db_name} -P workloads/workloada -P ${db_name}/${db_name}.properties \
        -p recordcount=$recordcount -p operationcount=$operationcount |tee -a $log 
    # pid=$(pgrep ycsb)
    # echo $pid >> $cgroup_path/cgroup.procs
    # wait $pid

    for type in a;do
        ./ycsb_lmdb -run -db ${db_name} -P workloads/workload${type} -P ${db_name}/${db_name}.properties \
            -p recordcount=$recordcount -p operationcount=$operationcount |tee -a $log 
        # pid=$(pgrep ycsb)
        # echo $pid >> $cgroup_path/cgroup.procs
        # wait $pid
    done
    cat $log|grep "Run th"|cut -d : -f 2|awk '{print $1/1000}'
done