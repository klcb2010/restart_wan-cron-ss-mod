#!/bin/bash

# 脚本版本信息
SCRIPT_VERSION="1.0"

# 日志文件路径
LOG_FILE="/jffs/scripts/restart_wan.log"

# 获取当前日期
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")

# 清空日志文件
echo "" > "$LOG_FILE"

# 记录脚本开始执行的日志
echo "[$CURRENT_DATE $SCRIPT_VERSION] - Script started." >> "$LOG_FILE"

# 记录脚本执行过程中的日志
# 重启WAN服务
echo "[$CURRENT_DATE $SCRIPT_VERSION] - Restarting WAN service..." >> "$LOG_FILE"
if service restart_wan; then
    echo "[$CURRENT_DATE $SCRIPT_VERSION] - WAN service restarted successfully." >> "$LOG_FILE"
else
    echo "[$CURRENT_DATE $SCRIPT_VERSION] - Failed to restart WAN service." >> "$LOG_FILE"
    exit 1  # 重启失败，退出脚本并返回错误码
fi

# 记录脚本结束执行的日志
echo "[$CURRENT_DATE $SCRIPT_VERSION] - Script finished." >> "$LOG_FILE"

# 脚本结束
exit 0
