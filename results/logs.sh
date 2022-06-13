#!/bin/bash

nextflow=~/Uni/SoSe22/MSPDS/nextflow/launch.sh

if [ $# -eq 0 ]; then
    last_job_name=$($nextflow log | cut -f3 | tail -1)
else
    last_job_name=$1
fi
 
$nextflow log $last_job_name -f workdir,name | awk '{print "echo " $2 " $(cat " $1 "/input_files.txt | sed 's/^/input:/') $(cat " $1 "/output_files.txt | sed 's/^/output:/')" }' | sh
