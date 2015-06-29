#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] ; then
  echo "Please provide four arguments:"
  echo "  - The letter of the workload"
  echo "  - The number of records."
  echo "  - The number of threads."
  echo "  - The target number of records for each thread."
  exit 1
fi

# Set some nice variables from the arguments
WORKLOAD=$1
RECORDCOUNT=$2
THREADS=$3
TARGET=$4

# Make sure the logs directory exists
mkdir -p logs

# Figure out how much memory we need, assuming 10 fields of 100 bytes each in each record
MEMORY=$(echo "(($RECORDCOUNT * 100 * 10 * 2) + 0.5) / 1" | bc)
if [ $MEMORY -gt 110000000000 ]
then
  echo "You're using more than 100GB of memory. Are you really sure you want to do that?"
elif [ $MEMORY -lt 10000000 ]
then
  echo "Using the minimum of 10MB of memory."
  MEMORY=10000000
else
  echo "Using $MEMORY bytes of memory."
fi

# Start the server
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR
cd quickcached
exec hotspot -Dappname=QC1 -Xms$MEMORY -Xmx$MEMORY -XX:CompileThreshold=1500 -XX:+UseConcMarkSweepGC \
  -jar dist/QuickCached-Server.jar -p 11211 -l 127.0.0.1 \
  > "../logs/w$WORKLOAD-r$RECORDCOUNT-th$THREADS-t$TARGET-server" 2>&1 &
SERVER_PID=$!
cd ..

# Wait until we're sure the server is started.
sleep 1

echo "Loading the data into the database..."
bin/ycsb load quickcached -P workloads/workload$WORKLOAD -p recordcount=$RECORDCOUNT \
  &> "logs/w$WORKLOAD-r$RECORDCOUNT-th$THREADS-t$TARGET-load"

echo "Running the benchmark on the data..."
bin/ycsb run quickcached -P workloads/workload$WORKLOAD -s -threads $THREADS -target $TARGET \
  &> "logs/w$WORKLOAD-r$RECORDCOUNT-th$THREADS-t$TARGET-run"

echo "Killing processes associated with the server:"
echo "  $(ps -o pgid= $SERVER_PID | grep -o '[0-9]*')"
kill -- -$(ps -o pgid= $SERVER_PID | grep -o '[0-9]*')
