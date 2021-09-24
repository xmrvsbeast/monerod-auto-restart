#!/bin/bash

#location of monerod scripts
script_dir="/path/to/scripts"

#location of monerod binary
monerod_dir="/usr/local/bin"

#if restart trigger file exists run monerod
while [ -f "$script_dir/monerod-restart.trigger" ]
do
	sleep 1
	$monerod_dir/monerod
done
