#!/bin/bash
#-XX:+UseParallelGC
exec hotspot -Dappname=QC1 -Xms100G -Xmx100G -XX:CompileThreshold=1500 -XX:+UseConcMarkSweepGC -jar dist/QuickCached-Server.jar $@
