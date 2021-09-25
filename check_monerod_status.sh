#!/bin/bash

#location of monerod scripts
script_dir="/path/to/scripts"

#location of monerod binary
monerod_dir="/usr/local/bin"

#set your restart uptime limits, example: 1 days 12 hours
uptime_days="1"
uptime_hours="12"

state_file="$script_dir/monerod-restart.active"

#find monerod screen
monerod_screen=$(screen -ls | awk '/monerod/ {print $1}')

#if monerod screen not running start it
if [ -z "$monerod_screen" ]; then
        date
        echo "Not Running, Starting..."
	screen -dmS monerod "$script_dir/monerod-run.sh"
	rm -f $state_file
        echo
	exit
fi

#check if monerod is responding via RPC
lbr_time=$(curl -s --max-time 2 http://127.0.0.1:18081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_last_block_header"}' -H 'Content-Type: application/json' |grep -Po 'timestamp": \K[^",]*')
	
#if RPC returning 0 value exit script, monerod syncing or not ready
if [ "$lbr_time" == "0" ];then echo "monerod running but not ready for RPC check" && date && echo && exit ;fi

#if RPC returning null value force kill monerod
if [ -z "$lbr_time" ];then 
	date
	echo "monerod not responding to RPC, force kill monerod"
	monerod_pid=$(pgrep monerod) && kill -9 "$monerod_pid"
	echo
	exit
fi

#check if script is already running
if [ -f "$state_file" ];then exit ;fi

#get monerod uptime values
monerod_uptime=$(monerod status |tail -2)
monerod_uptime_d=$(echo $monerod_uptime |awk '{printf $16}' |sed 's/d//g')
monerod_uptime_hr=$(echo $monerod_uptime |awk '{printf $17}' |sed 's/h//g')
monerod_uptime=$(echo "$monerod_uptime_d*24+$monerod_uptime_hr" |bc)
monerod_uptime_limit=$(echo "$uptime_days*24+$uptime_hours" |bc)

#start loop to check conditions for monerod restart
while [ "$monerod_uptime" -ge "$monerod_uptime_limit" ]
do
	date
	touch $state_file
	echo "monerod uptime is $monerod_uptime_d days and $monerod_uptime_hr, checking restart conditions"
	
	#check last block recorded time via RPC
	lbr_time=$(curl -s --max-time 1 http://127.0.0.1:18081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_last_block_header"}' -H 'Content-Type: application/json' |grep -Po 'timestamp": \K[^",]*')
	lbr_time=$(echo "($(date +%s) - $lbr_time)" |bc -l)

	#if LBR time is null force kill monerod
	if [ -z "$lbr_time" ];then 
		echo "Unable to get last block recorded time, forece kill monerod"
		monerod_pid=$(pgrep monerod) && kill -9 "$monerod_pid"
		echo
		rm -f $state_file
		exit
	fi

	#if LBR time is <= 60 seconds issue monerod stop command, otherwise wait and try again
	if [ "$lbr_time" -le "60" ];then
		echo "Last block recorded time is $lbr_time sec, restarting monerod..."
		echo "System memory usage before monerod restart"
		free -m
		$monerod_dir/monerod stop_daemon
		rm -f $state_file
		echo
		exit
	else
		echo "Last block recorded time is $lbr_time sec, delaying monerod restart"
		sleep 20
		monerod_uptime=$(monerod status |tail -2)
		monerod_uptime_d=$(echo $monerod_uptime |awk '{printf $16}' |sed 's/d//g')
		monerod_uptime_hr=$(echo $monerod_uptime |awk '{printf $17}' |sed 's/h//g')

		#check if monerod still needs to be restarted
		if [ "$monerod_uptime_d" -lt "1" ] && [ "$monerod_uptime_hr" -lt "1" ] ;then
			echo "monerod restarted outside of script, exiting"
			rm -f $state_file
			echo
		fi
	fi
done
