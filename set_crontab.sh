#!/bin/sh  
  
#  cron   
USER="klcb2010"  
  
#   
LOG_FILE="/jffs/scripts/set_crontab.log"  
  
# 
echo "$(date): set_crontab.sh start" >> "$LOG_FILE"  
  
# cron 
CRON_FILE="/jffs/scripts/crontabs/klcb2010"  
CRONTAB_FILE="/var/spool/cron/crontabs/$USER"  
  
#   
if [ -f "$CRON_FILE" ]; then  
    #  crontab  
    crontab -u $USER "$CRON_FILE"  
      
    #  crontab   
    if [ $? -eq 0 ]; then  
        echo "$(date): Cron tasks for $USER have been updated from $CRON_FILE" >> "$LOG_FILE"  
  
        #   
        # 
        chmod 777 "$CRONTAB_FILE"  
        if [ $? -eq 0 ]; then  
            echo "$(date): Crontab file permissions have been changed to 777" >> "$LOG_FILE"  
        else  
            echo "$(date): Failed to change crontab file permissions" >> "$LOG_FILE"  
        fi  
    else  
        #   
        echo "$(date): Failed to update cron tasks for $USER from $CRON_FILE" >> "$LOG_FILE"  
    fi  
else  
    #   
    echo "$(date): Cron tasks file $CRON_FILE does not exist!" >> "$LOG_FILE"  
fi  
  
#   
echo "$(date): set_crontab.sh ok" >> "$LOG_FILE"
