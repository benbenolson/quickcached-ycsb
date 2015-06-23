#!/bin/bash
set -e
set -o pipefail

# In order to compile this application, simply run `ant`, using the modified `build.xml` in this directory.
# Of course, the values in `build.xml` are relative to the location of this directory, so if you move it,
# also change the values in `build.xml`.

#Compile YCSB itself
cd core
mvn clean package
cd ..

# Compile QuickCached
cd quickcached
ant all
