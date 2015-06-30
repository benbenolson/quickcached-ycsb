#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]; then
  echo "Please provide five arguments:"
  echo "  - The name of the run that you're doing."
  echo "  - The letter of the workload."
  echo "  - The number of records."
  echo "  - The number of threads."
  echo "  - The target number of records for each thread."
  echo "  - (OPTIONAL) The amount of memory in bytes that the JVM should be allowed to have."
  exit 1
fi

# Set some nice variables from the arguments
NAME=$1
WORKLOAD=$2
RECORDCOUNT=$3
THREADS=$4
TARGET=$5

# Make sure the logs directory exists
mkdir -p logs/$NAME

# Figure out how much memory we need, assuming 10 fields of 100 bytes each in each record
# Or use the amount specified by the user
if [ -z "$6" ]; then
  MEMORY=110000000000
  echo "Automatically set the amount of memory being used to $MEMORY"
else
  MEMORY=$6
  if [ $MEMORY -gt 110000000000 ]; then
    echo "Using the maximum of 110GB of memory."
    MEMORY=110000000000
  elif [ $MEMORY -lt 10000000 ]; then
    echo "Using the minimum of 10MB of memory."
    MEMORY=10000000
  else
    echo "Manually set the amount of memory being used to $MEMORY"
  fi
fi

# Start the server
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR
cd quickcached
exec hotspot -Dappname=QC1 -Xms$MEMORY -Xmx$MEMORY -XX:CompileThreshold=1500 -XX:+UseConcMarkSweepGC \
  -XX:+PrintHeapAtGC -XX:+PrintGCDetails \
  -jar dist/QuickCached-Server.jar -p 11211 -l 127.0.0.1 \
  > "../logs/$NAME/w$WORKLOAD-r$RECORDCOUNT-th$THREADS-t$TARGET-m$MEMORY-server" 2>&1 &
SERVER_PID=$!
cd ..

# Wait until we're sure the server is started.
sleep 1

echo "Loading the data into the database..."
bin/ycsb load quickcached -P workloads/workload$WORKLOAD -p recordcount=$RECORDCOUNT \
  &> "logs/$NAME/w$WORKLOAD-r$RECORDCOUNT-th$THREADS-t$TARGET-m$MEMORY-load"

echo "Running the benchmark on the data..."
bin/ycsb run quickcached -P workloads/workload$WORKLOAD -s -threads $THREADS -target $TARGET \
  &> "logs/$NAME/w$WORKLOAD-r$RECORDCOUNT-th$THREADS-t$TARGET-m$MEMORY-run"

echo "Killing processes associated with the server:"
echo "  $(ps -o pgid= $SERVER_PID | grep -o '[0-9]*')"
kill -- -$(ps -o pgid= $SERVER_PID | grep -o '[0-9]*')
