#!/bin/sh
# 加载 SSH 公钥到 Dropbear
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM28EdHQ/f9eV2O17e34J5kJC1PQM8vj+YqGghHYo6dD u0_a491@localhost"

# 持久化目录
mkdir -p /jffs/.ssh
echo "$PUBKEY" > /jffs/.ssh/authorized_keys
chmod 600 /jffs/.ssh/authorized_keys

# 内存目录，供 Dropbear 使用
mkdir -p /tmp/home/root/.ssh
cp /jffs/.ssh/authorized_keys /tmp/home/root/.ssh/
chmod 600 /tmp/home/root/.ssh/authorized_keys

echo "SSH 公钥已加载"
