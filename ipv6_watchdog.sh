#!/bin/sh
# v6.38 - DDNS HTTPS 测试版：国内 ping + 外网 HTTPS 测试，不通重启 WAN + 推送（不报地址）

SCRIPT_VERSION="6.38"
LOG_DIR="/jffs/scripts"
CHECK_INTERVAL=3600          # 60分钟一次
WAN_COOLDOWN=180
KEEP_DAYS=0
PID_FILE="/var/run/ipv6_watchdog.pid"

DOMESTIC_DOMAINS="www.baidu.com www.sogou.com www.so.com www.taobao.com www.jd.com"

DDNS_HTTPS="https://.asuscomm.com:8443"  # 你的 DDNS HTTPS 测试地址

PUSHPLUS_TOKEN="39ac79848955463abaccb22fa28813"
PUSHPLUS_TITLE="路由器网络异常"
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
  cleanup_old_logs

  TARGET_DOMAIN=$(echo "$DOMESTIC_DOMAINS" | cut -d ' ' -f $INDEX)
  log "测试国内域名: $TARGET_DOMAIN (index $INDEX)"

  ping_ok=0
  if ping -c 3 -W 5 "$TARGET_DOMAIN" > /dev/null 2>&1; then
    ping_ok=1
    log "国内 ping 通过: $TARGET_DOMAIN"
  else
    log "国内 ping 失败: $TARGET_DOMAIN"
  fi

  foreign_ok=0
  if curl -s -I --connect-timeout 10 "$DDNS_HTTPS" > /dev/null 2>&1; then
    foreign_ok=1
    log "外网 HTTPS 测试通过: $DDNS_HTTPS"
  else
    log "外网 HTTPS 测试失败: $DDNS_HTTPS (超时或连接失败)"
  fi

  if [ $ping_ok -eq 0 ] || [ $foreign_ok -eq 0 ]; then
    msg="【网络异常】<br>$(date '+%Y-%m-%d %H:%M:%S')<br>国内域名 ping: $(if [ $ping_ok -eq 1 ]; then echo 通过; else echo 失败; fi) ($TARGET_DOMAIN)<br>外网 HTTPS 测试: $(if [ $foreign_ok -eq 1 ]; then echo 通过; else echo 失败; fi)<br>路由器正在自动重启WAN...<br>机型：GT-AX6000"
    log "异常触发 -> 重启 WAN"
    service restart_wan >> "$LOG_FILE" 2>&1
    log "WAN 已重启，冷却 ${WAN_COOLDOWN}秒"
    pushplus_notify "$msg"
    sleep "$WAN_COOLDOWN"
  else
    log "全部通过，继续监控"
  fi

  INDEX=$((INDEX + 1))
  if [ $INDEX -gt 5 ]; then
    INDEX=1
  fi

  sleep "$CHECK_INTERVAL"
done
