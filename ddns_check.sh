#!/bin/sh
# /jffs/scripts/ddns_check.sh - IPv6 DDNS 自愈脚本
#   1. 只判断 ddns_status 和 IPv6 变化
#   2. IPv6 变化会触发日志和重连
#   3. 日志中显示 ddns_status 和 IPv6，正常也记录，方便查看
#   4. last_ipv6 文件由本脚本生成，用于记录上一次 WAN IPv6

LOG_FILE="/jffs/scripts/ddns_check.log"
IP_FILE="/jffs/scripts/last_ipv6"
MAX_LINES=42
CHECK_INTERVAL=20  # 秒
MAX_RETRY=6
IP6_PORT=8443

mkdir -p "$(dirname "$LOG_FILE")"
NOW="$(date '+%Y-%m-%d %H:%M:%S')"

# ---------- 获取当前 WAN IPv6 ----------
CUR_IP=$(ip -6 addr show dev eth0 scope global | awk '/inet6/ {print $2}' | cut -d'/' -f1 | head -n1)
LAST_IP=""
[ -f "$IP_FILE" ] && LAST_IP="$(cat "$IP_FILE")"

# ---------- 放行防火墙 8443 ----------
ip6tables -C INPUT -p tcp --dport $IP6_PORT -j ACCEPT >/dev/null 2>&1 || \
ip6tables -I INPUT -p tcp --dport $IP6_PORT -j ACCEPT

# ---------- 获取 DDNS 状态 ----------
ddns_status=$(nvram get ddns_status | tr -d ' \t\r\n')

# ---------- DDNS 判断 ----------
if [ "$ddns_status" != "1" ] || [ "$CUR_IP" != "$LAST_IP" ]; then
    echo "$NOW - DDNS 异常或 IPv6 变化，ddns_status='$ddns_status'" >> "$LOG_FILE"

    if [ -n "$LAST_IP" ] && [ "$CUR_IP" != "$LAST_IP" ]; then
        echo "$NOW - 公网 IPv6 发生变化：$LAST_IP → $CUR_IP" >> "$LOG_FILE"
    fi

    # 重启 DDNS 服务
    service restart_ddns

    # 等待 DDNS 生效
    i=1
    success=""
    while [ $i -le $MAX_RETRY ]; do
        sleep $CHECK_INTERVAL
        ddns_status=$(nvram get ddns_status | tr -d ' \t\r\n')
        if [ "$ddns_status" = "1" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - DDNS 重连成功（第 $i 次检测），ddns_status='$ddns_status'" >> "$LOG_FILE"
            success=1
            break
        fi
        i=$((i + 1))
    done

    if [ -z "$success" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - DDNS 重连失败（已检测 $MAX_RETRY 次），ddns_status='$ddns_status'" >> "$LOG_FILE"
    fi
else
    echo "$NOW - DDNS 正常，IPv6 未变化，ddns_status='$ddns_status', IPv6='$CUR_IP'" >> "$LOG_FILE"
fi

# ---------- 记录当前 IPv6 ----------
[ -n "$CUR_IP" ] && echo "$CUR_IP" > "$IP_FILE"

# ---------- 日志裁剪 ----------
tail -n $MAX_LINES "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
