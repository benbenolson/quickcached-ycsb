#!/bin/bash
#-XX:+UseParallelGC
exec java -server -Dappname=QC1 -Xms8G -Xmx8G -XX:CompileThreshold=1500 -XX:+UseConcMarkSweepGC -jar dist/QuickCached-Server.jar $@
