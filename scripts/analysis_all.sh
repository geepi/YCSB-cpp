#!/bin/bash
output_path=/data/public/jyj/output/others/zipfian

# result=result.txt
# write Amplification  wiredtiger
for db_name in rocksdb lmdb;do
    log=$output_path/${db_name}/${db_name}.txt
    cat $log|grep "Write Amplification" # >> $result
done

# throughput
for db_name in rocksdb lmdb;do
    log=$output_path/${db_name}/${db_name}.txt
    cat $log|grep "throughput"
done

# latency
for db_name in rocksdb lmdb;do
    log=$output_path/${db_name}/${db_name}.txt
    cat $log|grep "100000000 operations;"| grep -o '\[[^]]*\]'|tr -d '[]'
done

# throught over time
# for db_name in rocksdb;do
#     log=$output_path/${db_name}/${db_name}.txt
#     awk -v RS='100000000 operations;' '{print $0 "100000000 operations;" > ("output" NR ".txt")}' $log
#     num=$(ls output*.txt |wc -l)
#     echo $num
#     for nr in $(seq 1 1 $(($num-1)));do
#         tmp_log=output${nr}.txt
#         sudo cat $tmp_log|grep -oP "sec:\s*\K(\d+)" \
#         |awk 'NR>1{print $1-delta ;delta=$1}' > $output_path/${db_name}/${db_name}_thput_overtime_${nr}.txt
#     done
#     rm output*.txt
# done

# bandwidth
for db_name in rocksdb;do
    # read bandwidth
    echo "Read Bandwidth"
    for type in load a b c d;do
        log=$output_path/${db_name}/${db_name}_${type}
        cat ${log}_bw.txt|grep -oP "Current DISK READ:\s*\K\d+.\d+" \
        |tee ${log}_read_bw.txt |awk '{sum+=$1} END{print sum/1000/NR "MB/s"}'
    done
    echo "Write Bandwidth"
    for type in load a b c d;do
        log=$output_path/${db_name}/${db_name}_${type}
        cat ${log}_bw.txt|grep -oP "Current DISK WRITE:\s*\K\d+.\d+" \
        |tee ${log}_write_bw.txt |awk '{sum+=$1} END{print sum/1000/NR "MB/s"}'
    done
done