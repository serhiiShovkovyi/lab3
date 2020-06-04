#!/bin/bash

_basePath="/home/grid/testbed/tb159/newLab3/autoVectProg/"

cd $_basePath

flags=(O0 O1 O2 O3 Os Ofast)

i=0
for flag in ${flags[@]}
do
        echo "g++ using flag $flag:"
        srcfile="result$i"
        g++ -$flag program.cpp -o $srcfile -lm
	j=0
        time (
	while [ $j -lt 100 ]
	do
		./$srcfile
		j=$((j+1))
	done
        let "i=i+1"
        echo -e "\n"
done

ml icc                                                                           

flagsForCpu=$(cat /proc/cpuinfo | grep flags | cut -d: -f2 | uniq)

flagsForOptimization=(O1 Ofast)

i=0

for optimizedFlag in ${flagsForOptimization[@]}
do

        for iccFlag in $flagsForCpu

        do
                srcfile="iccResult$iccFlag$optmzFlag"
                icc -$optimizedFlag -qopt-report-phase=vec program.cpp -o $srcfile -lm -x$iccFlag 2> errors.txt
                if [ $? -eq 0 ]
                then
                        echo "compilation with -$optimizedFlag flag and $iccFlag cpu extension:"
			j=0

                        time (

			while [ $j -lt 100]
			do
				./$srcfile
				j=$((j+1))
			done

			)
                        echo -e "\n"
                fi
        done
done
