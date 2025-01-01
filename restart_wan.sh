#!/bin/bash

# 脚本版本信息
SCRIPT_VERSION="1.0"

# 日志文件路径，按当天日期保存
LOG_FILE="/jffs/scripts/restart_wan_$(date +%Y-%m-%d).log"

# 清理非当天的日志文件
find /jffs/scripts/ -name "restart_wan_*.log" ! -name "$(basename "$LOG_FILE")" -type f -delete

# 记录脚本开始执行的日志
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
echo "[$CURRENT_DATE $SCRIPT_VERSION] - Script started." >> "$LOG_FILE"

# 重启WAN服务并记录日志
echo "[$CURRENT_DATE $SCRIPT_VERSION] - Restarting WAN service..." >> "$LOG_FILE"
if service restart_wan; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S") $SCRIPT_VERSION] - WAN service restarted successfully." >> "$LOG_FILE"
else
    echo "[$(date +"%Y-%m-%d %H:%M:%S") $SCRIPT_VERSION] - Failed to restart WAN service." >> "$LOG_FILE"
    exit 1  # 重启失败，退出脚本并返回错误码
fi

# 记录脚本结束执行的日志
echo "[$(date +"%Y-%m-%d %H:%M:%S") $SCRIPT_VERSION] - Script finished." >> "$LOG_FILE"

# 脚本结束
exit 0
