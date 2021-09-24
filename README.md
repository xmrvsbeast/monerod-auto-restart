# monerod-auto-restart

These scripts will allow you to manage monerod restarts automatically.
It will check if monerod is running, responsive, and in need of a restart based on a uptime that you can set

**Change the the variables in each script to match your filesystem paths**

#location of monerod scripts
script_dir="/path/to/scripts"

#location of monerod binary
monerod_dir="/usr/local/bin"

**Add a cron job to run the check script**

crontab -e

#Check Monerod Status cron job, runs check every 5 minutes

*/5 * * * * /path/to/scripts/check_monerod_status.sh >> /path/to/scripts/log/check_monerod_status.log

**Disable/Enable auto-restart**

mv -f monerod-restart.trigger monerod-restart.trigger-off

mv -f monerod-restart.trigger-off monerod-restart.trigger
