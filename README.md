# monerod-auto-restart

These scripts will allow you to manage monerod restarts automatically.
It will check if monerod is running, responsive, and in need of a restart based on a uptime that you can set.

**Dependencies**

screen, curl, pgrep, bc

**Change the the variables in both scripts to match your filesystem paths**

    #location of monerod scripts
    script_dir="/path/to/scripts"

    #location of monerod binary
    monerod_dir="/usr/local/bin"

    #set your restart uptime limits, example: 1 days 12 hours
    uptime_days="1"
    uptime_hours="12"

Then stop your monerod, we will let the script start and manage it.  A screen session is started you can attach to it by the command

    screen -S monerod

**Add a cron job to run the check script**

crontab -e

    #Check Monerod Status cron job, runs check every 5 minutes
    */5 * * * * /path/to/scripts/check_monerod_status.sh >> /path/to/scripts/log/check_monerod_status.log

**Run the script**

Make the scripts executable 

    chmod +x check_monerod_status.sh monerod-run.sh

Now you can run the check_monerod_status.sh script and it will start monerod, or wait for the cron job to kick it off

**Disable/Enable auto-restart**

If the file "monerod-restart.trigger" is removed or renamed and monerod is terminated it will not auto-restart, useful if you are going to shutdown/restart the system or do other work which requires monerod to not be running.

    mv -f monerod-restart.trigger monerod-restart.trigger-off
    mv -f monerod-restart.trigger-off monerod-restart.trigger

