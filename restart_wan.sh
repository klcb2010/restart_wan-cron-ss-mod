#!/bin/bash  
# /jffs/scripts/restart_wan.sh  
  
# 设置日志文件路径（与脚本同目录）  
LOG_FILE="/jffs/scripts/restart_wan.log"  
  
# 获取当前日期的日部分  
CURRENT_DAY=$(date +"%d")  
  
# 检查当前日期是否为偶数（能被2整除）  
if ((CURRENT_DAY % 2 == 0)); then  
    # 如果是偶数日期，则执行以下操作  
    echo "$(date) - Starting restart_wan.sh on even day" >> "$LOG_FILE"  
  
    # 执行重启命令，并将输出也记录到日志中  
    /sbin/service restart_wan >> "$LOG_FILE" 2>&1  
  
    # 检查上一个命令的退出状态，并在日志中记录  
    if [ $? -eq 0 ]; then  
        echo "$(date) - Service restart_wan restarted successfully on even day" >> "$LOG_FILE"  
    else  
        echo "$(date) - Failed to restart service restart_wan on even day" >> "$LOG_FILE"  
    fi  
  
    # 写入执行结束的日志  
    echo "$(date) - Finished restart_wan.sh on even day" >> "$LOG_FILE"  
else  
    # 如果不是偶数日期，则记录日志但不执行重启  
    echo "$(date) - Skipping restart_wan.sh on odd day" >> "$LOG_FILE"  
fi