#!/bin/sh

# 等待网络、证书、硬盘完全就绪（你路由器 60-90 秒够用）
sleep 90

# 防止重复启动
if ! pgrep -f "rclone serve webdav" > /dev/null; then
    nohup /opt/bin/rclone serve webdav /tmp/mnt/SD/ --addr :8080 \
    --user 英文用户名 --pass 字母数字密码 \
    --cert /etc/cert.pem --key /etc/key.pem \
    > /tmp/rclone.log 2>&1 &
    logger "rclone WebDAV (HTTPS) started successfully"
else
    logger "rclone WebDAV already running"
fi
