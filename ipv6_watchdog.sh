#!/bin/sh
# v6.34 - 正式版：顺序轮换域名 ping，只保留当天日志（强制清理）

SCRIPT_VERSION="6.34"
LOG_DIR="/jffs/scripts"
CHECK_INTERVAL=3600          # 60分钟一次
WAN_COOLDOWN=180
PID_FILE="/var/run/ipv6_watchdog.pid"

DOMESTIC_DOMAINS="www.baidu.com www.sogou.com www.so.com www.taobao.com www.jd.com"

PUSHPLUS_TOKEN="token"
PUSHPLUS_TITLE="路由器国内网络异常"
PUSHPLUS_URL="http://www.pushplus.plus/send"

mkdir -p "$LOG_DIR"

if [ -f "$PID_FILE" ]; then
  OLD_PID=$(cat "$PID_FILE")
  if kill -0 "$OLD_PID" 2>/dev/null && [ "$OLD_PID" != "$$" ]; then
    exit 0
  fi
  rm -f "$PID_FILE"
fi
echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

log() {
  LOG_FILE="$LOG_DIR/ipv6_watchdog_$(date +%Y-%m-%d).log"
  touch "$LOG_FILE" 2>/dev/null
  echo "[$(date '+%Y-%m-%d %H:%M:%S') $SCRIPT_VERSION] $1" >> "$LOG_FILE" 2>/dev/null
}

pushplus_notify() {
  local content="$1"
  curl -s -X POST "$PUSHPLUS_URL" \
    -d "token=$PUSHPLUS_TOKEN" \
    -d "title=$PUSHPLUS_TITLE" \
    -d "content=$content" \
    -d "template=html" > /dev/null 2>&1
}

cleanup_old_logs() {
  TODAY_FILE="ipv6_watchdog_$(date +%Y-%m-%d).log"
  find "$LOG_DIR" -type f -name 'ipv6_watchdog_*.log' ! -name "$TODAY_FILE" -delete 2>/dev/null
}

cleanup_old_logs
log "看门狗已启动 v$SCRIPT_VERSION"

INDEX=1

while true; do
  cleanup_old_logs  # 每轮开始前清理旧日志

  TARGET_DOMAIN=$(echo "$DOMESTIC_DOMAINS" | cut -d ' ' -f $INDEX)
  log "测试域名: $TARGET_DOMAIN (index $INDEX)"

  if ping -c 3 -W 5 "$TARGET_DOMAIN" > /dev/null 2>&1; then
    log "Ping 通过: $TARGET_DOMAIN"
  else
    msg="【国内网络异常】<br>$(date '+%Y-%m-%d %H:%M:%S')<br>ping $TARGET_DOMAIN 失败<br>路由器正在自动重启WAN...<br>机型：GT-AX6000"
    log "Ping 失败: $TARGET_DOMAIN -> 重启 WAN"
    service restart_wan >> "$LOG_FILE" 2>&1
    log "WAN 已重启，冷却 ${WAN_COOLDOWN}秒"
    pushplus_notify "$msg"
    sleep "$WAN_COOLDOWN"
  fi

  INDEX=$((INDEX + 1))
  if [ $INDEX -gt 5 ]; then
    INDEX=1
  fi

  sleep "$CHECK_INTERVAL"
done
