#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] ; then
  echo "Please provide two arguments: the letter of the workload, and the number of records."
  exit 1
fi

WORKLOAD=$1
RECORDCOUNT=$2

bin/ycsb load quickcached -P workloads/workload$WORKLOAD -p recordcount=$RECORDCOUNT
bin/ycsb run quickcached -P workloads/workload$WORKLOAD -p recordcount=$RECORDCOUNT
