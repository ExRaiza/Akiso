#!/bin/bash

sectors_read2=`cat /proc/diskstats | awk '{print $6}' | head -n 1`
sectors_write2=`cat /proc/diskstats | awk '{print $10}' | head -n 1`
SECONDS=0
time1=0
time2=0
sum1=0
sum2=0
i=0
tput civis
#tput cvvis


while [ 1 -eq 1 ]
do
	read_speed=0
	write_speed=0
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
		time1=$(($SECONDS-$sum1))
		((sum1+=time1))
		sectors_rdiff=`echo "$sectors_read - $sectors_read2" | bc`
		sectors_read2=$sectors_read
		read_speed=`echo "$sectors_rdiff*512/$time1" | bc`
	fi

	tput cup 20 0
	printf "LOL"
	echo `echo "$sectors_rdiff*512/$time1" >>  bc`


	if ! [ $sectors_write -eq $sectors_write2 ] 
	then 
		time2=$(($SECONDS-$sum2))
		((sum2+=time2))
		sectors_wdiff=`echo "$sectors_write - $sectors_write2" | bc`
		sectors_write2=$sectors_write
		if [ $time2 -gt 0 ]
		then
			write_speed=`echo "$sectors_wdiff*512/$time2" | bc`

		fi
	fi

	#tput clear

	arr_write[$i]=`echo "$write_speed/1000" | bc`
	arr_read[$i]="$read_speed"
	arr_cpu[$i]="$cpu"

	IFS=$'\n'
	maxR=`echo "${arr_read[*]}" | sort -nr | head -n1`
	compR=$((maxR/15))
	maxW=`echo "${arr_write[*]}" | sort -nr | head -n1`
	compW=$((maxW/15))
	maxC=`echo "${arr_cpu[*]}" | sort -nr | head -n1`
	compC=`echo "$maxC / 15" |  bc`
	IFS=

	if [ $compR -eq 0 ] 
	then
		compR=15
	fi

	if [ $compW -eq 0 ] 
	then
		compW=15
	fi

	if [ $compC -eq 0 ] 
	then
		compC=15
	fi

	for counter in ${!arr_write[@]}
    do 
    	tput cup $(($counter+1)) 0
    	tput setab 1
    	length=$(( ${arr_write[counter]}/$compW ))
		printf '%*s' "$length"
		tput sgr0
		printf " ${arr_write[counter]} KB/s"
    done

    for counter in ${!arr_read[@]}
    do 
    	tput cup $(($counter+1)) 30
    	tput setab 1
    	length=$(( ${arr_read[counter]}/$compR ))
		printf '%*s' "$length"
		tput sgr0
		printf " ${arr_read[counter]} B/s"
    done

    for counter in ${!arr_cpu[@]}
    do 
    	tput cup $(($counter+1)) 60
    	tput setab 1
    	length=`echo "${arr_cpu[counter]}/$compC" | bc `
		printf '%*s' "$length"
		tput sgr0
		printf " ${arr_cpu[counter]}"
    done


    text=0;
	text2=0
	if [ $write_speed -gt 1000 ] && [ $write_speed -lt 1000000 ] 
	then
		write_speed=`echo "$write_speed/1000" | bc`
		text="write $write_speed KB/s"
	elif [ $write_speed  -gt 1000000 ] 
	then
		write_speed=`echo "$write_speed/1000000" | bc`
		text="write $write_speed MB/s"
	else
		text="write $write_speed B/s"
	fi

	if [ $read_speed -gt 1000 ] && [ $read_speed -lt 1000000 ] 
	then
		read_speed=$(($read_speed/1000))
		text2=" read $read_speed KB/s"
	elif [ $read_speed  -gt 1000000 ] 
	then
		read_speed=$(($read_speed/1000))
		text2="read $read_speed MB/s"
	else
		text2="read $read_speed B/s"
	fi

	tput cup 0 0
	echo "$text"
	tput cup 0 30
	echo "$text2"
	tput cup 0 60
	#printf "LOL"
	#echo "CPU $cpu"

	if [ $i -gt 8 ] 
	then
		((i--))
		for counter in {0..8}
        do
            arr_write[$counter]=${arr_write[$(($counter+1))]}
            arr_read[$counter]=${arr_read[$(($counter+1))]}
        done
	fi

	((i++))
done
