#!/bin/sh

sleep 90

# 如果已经有 rclone 在跑，就直接退出
if pgrep -f "rclone serve webdav" > /dev/null; then
    logger "rclone WebDAV already running"
    exit 0
fi

# 启动 WebDAV
nohup /opt/bin/rclone serve webdav /tmp/mnt/SD/ \
  --addr 0.0.0.0:8181 \
  --user 字母数字 \
  --pass 字母数字 \
  --cert /etc/cert.pem \
  --key /etc/key.pem \
  > /tmp/rclone.log 2>&1 &

logger "rclone WebDAV started on 8181"
