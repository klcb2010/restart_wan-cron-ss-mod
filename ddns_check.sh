#!/bin/sh
# 文件名：/jffs/scripts/ddns_check.sh
# 功能：检测华硕 DDNS 是否在线，异常立即触发重连
# 日志文件，只保留最近一周记录
LOG_FILE="/jffs/scripts/ddns_check.log"
DDNS_DOMAIN="klcb2012.asuscomm.com"
MAX_LINES=42  # 4小时一次，一周大约42条记录

# 确保日志目录存在
mkdir -p $(dirname "$LOG_FILE")

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 检测 DDNS 是否可达
if ping -c 1 -W 2 $DDNS_DOMAIN >/dev/null 2>&1; then
    # DDNS 正常，只写日志，不重连
    echo "$TIMESTAMP - DDNS 正常" >> $LOG_FILE
else
    # DDNS 异常，立即重连
    service restart_ddns
    echo "$TIMESTAMP - DDNS 异常，已重连" >> $LOG_FILE
fi

# 保留最近 MAX_LINES 条日志
if [ -f "$LOG_FILE" ]; then
    tail -n $MAX_LINES "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
