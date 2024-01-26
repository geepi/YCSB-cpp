#!/bin/bash

make clean && make BIND_ROCKSDB=1 -lpthread -lsnappy  -lz -lbz2 -lzstd

for 