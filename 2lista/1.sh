#!/bin/bash

sectors_read2=`cat /proc/diskstats | awk '{print $6}' | head -n 1`
sectors_write2=`cat /proc/diskstats | awk '{print $10}' | head -n 1`
SECONDS=0
time1=0
time2=0
sum1=0
sum2=0

while [ 1 -eq 1 ]
do
	read_speed=0
	write_speed=0
	#cat /proc/diskstats
	cpu=`cat /proc/loadavg | awk '{print $1}' | head -n 1`
	sectors_read=`cat /proc/diskstats | awk '{print $6}' | head -n 1`
	sectors_write=`cat /proc/diskstats | awk '{print $10}' | head -n 1`

	sleep 1

	if [ $time1 -gt 10 ]
	then
		read_speed=0
	fi
	
	if ! [ $sectors_read -eq $sectors_read2 ]
	then 
		time1=$(($SECONDS-$time1))
		((sum1+=time1))
		sectors_rdiff=$(($sectors_read - $sectors_read2))
		sectors_read2=$sectors_read
		read_speed=$(( $sectors_rdiff*512/$time1 ))
	fi

	if ! [ $sectors_write -eq $sectors_write2 ] 
	then 
		time2=$(($SECONDS-$sum2))
		((sum2+=time2))
		sectors_wdiff=$(($sectors_write - $sectors_write2))
		sectors_write2=$sectors_write
		if [ $time2 -gt 0 ]
		then
			write_speed=$(( $sectors_wdiff*512/$time2 ))

		fi
	fi


	text=0;
	if [ $write_speed -gt 1000 ] && [ $write_speed -lt 1000000 ] 
	then
		write_speed=$(($write_speed/1000))
		text="write $write_speed KB/s"
	elif [ $write_speed  -gt 1000000 ] 
	then
		write_speed=$(($write_speed/1000000))
		text="write $write_speed MB/s"
	else
		text="write $write_speed B/s"
	fi

	if [ $read_speed -gt 1000 ] && [ $read_speed -lt 1000000 ] 
	then
		read_speed=$(($read_speed/1000))
		text="$text || read $read_speed KB/s"
	elif [ $read_speed  -gt 1000000 ] 
	then
		read_speed=$(($read_speed/1000))
		text="$text || read $read_speed MB/s"
	else
		text="$text || read $read_speed B/s"
	fi

	echo "$text || CPU $cpu"

done




