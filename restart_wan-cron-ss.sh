#!/bin/bash

# 定义目录和文件URL
BASE_URL="https://cors.isteed.cc/raw.githubusercontent.com/klcb2010/restart_wan-cron-ss-mod/main/"
DEST_DIR_SCRIPTS="/jffs/scripts/"

# 检查用户是否有在目标目录下写入的权限
if [ ! -w "$DEST_DIR_SCRIPTS" ]; then
    echo "Warning: You do not have write permissions to $DEST_DIR_SCRIPTS. Assigning full permissions (777)."
    # 赋予777权限，请谨慎使用此操作
    chmod 777 "$DEST_DIR_SCRIPTS"
    # 检查权限是否已经更改
    if [ ! -w "$DEST_DIR_SCRIPTS" ]; then
        echo "Error: Failed to assign permissions to $DEST_DIR_SCRIPTS"
        exit 1
    fi
fi

# 创建目标目录（如果不存在）
mkdir -p "$DEST_DIR_SCRIPTS"

# 下载文件并记录日志
function download_file {
    local url=$1
    local dest=$2
    curl -L -o "$dest" "$url" || {
        echo "Error: Failed to download $url to $dest"
        exit 1
    }
    echo "Downloaded $url to $dest"
}

# 赋予执行权限给shell脚本文件
function chmod_script {
    local script=$1
    chmod 777 "$script" || {
        echo "Error: Failed to set permissions to 777 for $script"
        exit 1
    }
    echo "Set permissions to 777 for $script"
}

# 执行脚本并记录日志
function execute_script {
    local script=$1
    echo "Executing $script..."
    "$script" || {
        echo "Error: $script failed with exit code $?"
        exit 1
    }
    echo "$script executed successfully."
}

# 下载文件
download_file "$BASE_URL/restart_wan.sh" "$DEST_DIR_SCRIPTS/restart_wan.sh"
download_file "$BASE_URL/set_crontab.sh" "$DEST_DIR_SCRIPTS/set_crontab.sh"
download_file "$BASE_URL/ss_rule_update.sh" "$DEST_DIR_SCRIPTS/ss_rule_update.sh"
download_file "$BASE_URL/ss_online_update.sh" "$DEST_DIR_SCRIPTS/ss_online_update.sh"
download_file "$BASE_URL/cron" "$DEST_DIR_SCRIPTS/cron"

# 赋予执行权限
chmod_script "$DEST_DIR_SCRIPTS/restart_wan.sh"
chmod_script "$DEST_DIR_SCRIPTS/set_crontab.sh"
chmod_script "$DEST_DIR_SCRIPTS/ss_rule_update.sh"
chmod_script "$DEST_DIR_SCRIPTS/ss_online_update.sh"

# 执行脚本
execute_script "$DEST_DIR_SCRIPTS/set_crontab.sh"

echo "All scripts executed successfully."
