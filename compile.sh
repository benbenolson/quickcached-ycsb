#!/bin/bash
set -e
set -o pipefail

# Get into the directory that this script is stored in
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR

# Make sure ant is ready and compiled
cd utils
tar xf apache-ant-1.9.5-src.tar.gz
cd apache-ant-1.9.5
sh build.sh -Ddist.dir=$DIR/utils/ant dist
cd ..

# Set up some nice environment variables
export ANT_HOME=$DIR/utils/ant
export M2_HOME=$DIR/utils/maven

# Make sure maven is ready and compiled
tar xf apache-maven-3.2.5-src.tar.gz
cd apache-maven-3.2.5
yes yes | ant

# Get out of the utils directory
cd ../..

# Now set your PATH accordingly
export PATH="$PATH:$DIR/utils/ant/bin:$DIR/utils/maven/bin"

# Compile YCSB itself
cd core
mvn clean package
cd ..

# Compile QuickCached
cd quickcached
ant all
