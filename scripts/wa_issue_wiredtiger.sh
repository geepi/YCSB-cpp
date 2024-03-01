#!/bin/bash

recordcount=100000
operationcount=100000
log_path=/data/public/jyj/output/$(date +%F)
log=$log_path/wa_configure.txt


for pair in 16 64 256 1024 4096;do
    value=$(($pair-8))
    sed -i "s/fieldlength=.*/fieldlength=$value/" workloads/updateonly
    sed -i "s/fieldlength=.*/fieldlength=$value/" workloads/readsequential_only

    rm -rf /tmp/ycsb-wiredtiger
    ./ycsb -load -db wiredtiger -P workloads/updateonly -P wiredtiger/wiredtiger.properties \
           -p recordcount=$recordcount -p operationcount=$operationcount |tee -a $log
    ./ycsb -run -db wiredtiger -P workloads/updateonly -P wiredtiger/wiredtiger.properties \
           -p recordcount=$recordcount -p operationcount=$operationcount |tee -a $log
    ./ycsb -run -db wiredtiger -P workloads/readsequential_only -P wiredtiger/wiredtiger.properties \
           -p recordcount=$recordcount -p operationcount=$operationcount |tee -a $log
done
cat $log|grep "wchar" |cut -d : -f 2 #|awk 'NR%2{even=$0} !(NR%2){print ($0-even)}'
