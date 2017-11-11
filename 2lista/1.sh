#!/bin/bash

sectors_read2=`cat /proc/diskstats | grep sda | awk '{print $6}' | head -n 1`
sectors_write2=`cat /proc/diskstats | grep sda | awk '{print $10}' | head -n 1`
SECONDS=0
time1=0
time2=0
sum1=0
sum2=0
i=0
tput civis
#tput cvvis

tput clear

function doMagic () {
	return=$1
	if (( `echo "$return > 1024" | bc` )) && (( `echo "$return  < 1048576" | bc` ))
	then
		return=`echo "scale=2;$return/1024" | bc | awk '{printf "%.2f", $0}'`
		return="$return KB/s"
	elif (( `echo "$return > 1048576" | bc` ))
	then
		return=`echo "scale=2;$return/1048576" | bc | awk '{printf "%.2f", $0}'`
		return="$return MB/s"
	else
		return="$return B/s"
	fi
}

while [ 1 -eq 1 ]
do
	#sleep 1	
	read_speed=0
	write_speed=0
	cpu=`cat /proc/loadavg | awk '{print $1}' | head -n 1 | awk '{printf "%.2f", $0}'`
	#cpu=`echo $cpu | awk '{printf "%.2f", $0}'`
	sectors_read=`cat /proc/diskstats | awk '{print $6}' | head -n 1`
	sectors_write=`cat /proc/diskstats | awk '{print $10}' | head -n 1`
	
	if [ $time1 -eq 0 ]
	then
		time1=1
	fi

	if [ $time2 -eq 0 ]
	then
		time2=1
	fi

	if ! [ $sectors_read -eq $sectors_read2 ]
	then 
		time1=$(($SECONDS-$sum1))
		((sum1+=$time1))		
		sectors_rdiff=$(("$sectors_read - $sectors_read2"))
		sectors_read2=$sectors_read		
		read_speed=`echo "scale=3;$sectors_rdiff*512/$time1" | bc | awk '{printf "%.3f", $0}'`
	fi

	if ! [ $sectors_write -eq $sectors_write2 ] 
	then 
		time2=$(($SECONDS-$sum2))		
		((sum2+=time2))
		sectors_wdiff=$(("$sectors_write - $sectors_write2"))
		sectors_write2=$sectors_write
		write_speed=$(("$sectors_wdiff*512/$time2"))
	fi

	doMagic $write_speed
   	text=$return
   	doMagic $read_speed
   	text2=$return

   	leng=`printf "$((30-${#text}-8))"`
   	tput cup 0 0 
   	leng2=`printf "$((30-${#text2}-7))"`
   	bufor=`printf "write $text %*s read $text2" $leng`
   	bufor=`printf "$bufor %*s CPU $cpu" $leng2`
   	echo $bufor
	#tput cup 0 0
	#echo "write $text"
	#tput cup 0 30
	#echo "read $text2"
	#tput cup 0 60
	#echo "CPU $cpu"



	if (( `echo "$write_speed == 0" | bc ` ))
	then 
		arr_write[$i]=0
	else
		arr_write[$i]=$write_speed
	fi
	if (( `echo "$read_speed == 0" | bc ` ))
	then 
		arr_read[$i]=0
	else
		arr_read[$i]=$read_speed
	fi
	arr_cpu[$i]="$cpu"

	IFS=$'\n'
	maxR=`echo "${arr_read[*]}" | sort -nr | head -n1`
	compR=`echo "scale=3;$maxR/15" | bc | awk '{printf "%.3f", $0}'`	
	maxW=`echo "${arr_write[*]}" | sort -nr | head -n1`
	compW=`echo "scale=3;$maxW/15" | bc | awk '{printf "%.3f", $0}'`
	maxC=`echo "${arr_cpu[*]}" | sort -nr | head -n1`
	compC=`echo "scale=3;$maxC/15" | bc | awk '{printf "%.3f", $0}'`
	IFS=

	if (( `echo "$compR == 0" | bc` ))
	then
		compR=15
	fi

	if (( `echo "$compW == 0" | bc` ))
	then
		compW=15
	fi

	if (( `echo "$compC == 0 " | bc -l` ))
	then
		compC=15
	fi

	unset bufor
	
	for counter in ${!arr_write[@]}
    do 
    	tput cup $(($counter+1)) 0
    	length=`echo "scale=0;${arr_write[counter]} / $compW" | bc | awk '{printf "%.0f", $0}'`
		bufor=`printf '\e[41m%*s\e[0m' "$length"`
		doMagic ${arr_write[counter]}
		txt=$return
		bufor="$bufor $txt"
		temp=`printf "$((30-$length-${#txt}-2))"`
		txt=`printf "%*s|" "$temp"`
		bufor="$bufor$txt"

		length=`echo "scale=0;${arr_read[counter]} / $compR" | bc | awk '{printf "%.0f", $0}'`
		bufor=`printf "$bufor\e[41m%*s\e[0m" "$length"`
		doMagic ${arr_read[counter]}
		txt=$return
		bufor="$bufor $txt"
		temp=`printf "$((30-$length-${#txt}-2))"`
		txt=`printf "%*s|" "$temp"`
		bufor="$bufor$txt"

		length=`echo "scale=1;${arr_cpu[counter]}/$compC" | bc | awk '{printf "%d", $0}'`
		bufor=`printf "$bufor\e[41m%*s\e[0m" "$length"`
		txt=`printf "${arr_cpu[$counter]} %*s" 10`
		bufor="$bufor $txt"

		echo $bufor
    done

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