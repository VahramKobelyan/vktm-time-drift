#!/bin/bash

rm -f orcl0?_vktm_*.csv

for vktmTraceFile in trace/*vktm*.trc
do
	fullFileName=$(basename $vktmTraceFile)
	#fileName=$(echo $fullFileName | cut -f1 -d\. )
	fileName=$(echo $fullFileName | awk -F_ '{ print $1"-"$2 }')
	csvFile="${fileName}.csv"

	echo "csvFile: $csvFile"
	#echo "fullFileName: $fullFileName"

	./vt.pl --csv-output $vktmTraceFile >> $csvFile

done



