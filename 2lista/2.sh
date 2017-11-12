#!/bin/bash

printf "PID    | PPID    | STATE | PGRP    | SESS    | TTY | OPEN FILES \n"

find /proc -mindepth 2 -maxdepth 2 -type f -name stat | while read dire
do
	
	t1=`cat $dire 2> /dev/null | awk '{print $1}'`
	t2=`cat $dire 2> /dev/null | awk '{print $4}'`
	t3=`cat $dire 2> /dev/null | awk '{print $3}'`
	t4=`cat $dire 2> /dev/null | awk '{print $5}'`
	t5=`cat $dire 2> /dev/null | awk '{print $6}'`
	t6=`cat $dire 2> /dev/null | awk '{print $7}'`

	if [[ $t1 != "" ]]
	then
		bufor=$t1
		txt=`printf "%*s" "$((8-${#t1}))"`
		bufor="$bufor$txt"
		txt=`printf "$t2%*s" $((10-${#t2}))`
		bufor="$bufor$txt"
		txt=`printf "$t3%*s" $((8-${#t3}))`
		bufor="$bufor$txt"
		txt=`printf "$t4%*s" $((10-${#t4}))`
		bufor="$bufor$txt"
		txt=`printf "$t5%*s" $((10-${#t5}))`
		bufor="$bufor$txt"
		txt=`printf "$t6%*s" $((6-${#t6}))`
		bufor="$bufor$txt"
		dire=${dire%/*}
		open=`ls $dire/fd 2> /dev/null | wc -l`
		txt=`printf "$open \n"`
		bufor="$bufor$txt"
		echo -e "$bufor"
	fi
done
