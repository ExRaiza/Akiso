#!/bin/bash

printf "PID    | PPID    | STATE | PGRP    | SESS    | TTY | OPEN FILES \n"

find /proc -maxdepth 1 -type d | grep -o '[0-9]*' | while read dire
do
	cd /proc/$dire 2>/dev/null
	t1=`cat stat | awk '{print $1}'`
	t2=`cat stat | awk '{print $4}'`
	t3=`cat stat | awk '{print $3}'`
	t4=`cat stat | awk '{print $5}'`
	t5=`cat stat | awk '{print $6}'`
	t6=`cat stat | awk '{print $7}'`
	#printf "$t1 ${#t1}"
	printf "$t1%*s" $((8-${#t1})) 
	printf "$t2%*s" $((10-${#t2}))
	printf "$t3%*s" $((8-${#t3}))
	printf "$t4%*s" $((10-${#t4}))
	printf "$t5%*s" $((10-${#t5}))
	printf "$t6%*s" $((6-${#t6}))
	open=`ls ./fd | wc -l`
	printf " $open\n"
done
