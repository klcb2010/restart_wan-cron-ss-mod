#!/bin/sh
# httpd_watch v2.0 - 进程检查 + 证书 HTTPS 测试
SCRIPT_VERSION="2.0"

LOG_FILE="/tmp/httpd_watch.log"
DDNS_HTTPS="https://.asuscomm.com:8443"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" 2>/dev/null
}

# 获取当前 IPv6
CUR_IP=$(ip -6 addr show dev eth0 scope global 2>/dev/null | awk '/inet6 / {print $2}' | cut -d/ -f1 | head -n1)

# 测试证书/HTTPS 是否通
https_ok=1
TEST_URL="https://[$CUR_IP]:8443"
curl -s -I -k --connect-timeout 10 --max-time 20 "$TEST_URL" >/dev/null 2>&1 || https_ok=0

if [ $https_ok -eq 0 ]; then
  log "证书/HTTPS 测试失败 → 重启 httpd"
  service restart_httpd
  log "httpd 已重启"
elif [ -z "$(pidof httpd)" ]; then
  log "httpd 进程不存在 → 重启 httpd"
  service restart_httpd
  log "httpd 已重启"
else
  log "状态正常"
fi
