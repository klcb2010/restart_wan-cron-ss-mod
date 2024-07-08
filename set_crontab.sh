#!/bin/sh

# cron 用户
USER="klcb2010"

# 日志文件路径
LOG_FILE="/jffs/scripts/set_crontab.log"

# 清空日志文件
echo "" > "$LOG_FILE"

# 记录脚本开始执行的时间
echo "$(date): set_crontab.sh start" >> "$LOG_FILE"

# 等待一段时间确保系统初始化完成
sleep 10

# cron 文件路径
CRON_FILE="/jffs/scripts/cron"
CRONTAB_FILE="/var/spool/cron/crontabs/$USER"

# 检查 CRON_FILE 是否存在，如果不存在则尝试创建
if [ ! -f "$CRON_FILE" ]; then
    # 注意：通常不推荐直接创建 crontab 文件并设置777权限
    # 但如果您确实需要这样做，请确保您知道潜在的安全风险
    touch "$CRON_FILE"
    if [ $? -eq 0 ]; then
        echo "$(date): Cron tasks file $CRON_FILE has been created." >> "$LOG_FILE"
        # 设置文件权限（不推荐使用777，除非您完全清楚为什么需要这样做）
        chmod 777 "$CRON_FILE"
        if [ $? -eq 0 ]; then
            echo "$(date): Cron tasks file permissions have been set to 777 (WARNING: This is insecure!)" >> "$LOG_FILE"
        else
            echo "$(date): Failed to set permissions for $CRON_FILE" >> "$LOG_FILE"
        fi
    else
        echo "$(date): Failed to create cron tasks file $CRON_FILE" >> "$LOG_FILE"
        exit 1  # 退出脚本，因为无法继续
    fi
fi

# 如果 CRON_FILE 存在，则更新 crontab
if [ -f "$CRON_FILE" ]; then
    # crontab 更新
    crontab -u $USER "$CRON_FILE"

    # 检查是否成功更新了 crontab
    if [ $? -eq 0 ]; then
        echo "$(date): Cron tasks for $USER have been updated from $CRON_FILE" >> "$LOG_FILE"
    else
        echo "$(date): Failed to update cron tasks for $USER from $CRON_FILE" >> "$LOG_FILE"
    fi
else
    # 如果 CRON_FILE 在之前没有被创建（或仍然存在其他问题）
    echo "$(date): Cron tasks file $CRON_FILE does not exist!" >> "$LOG_FILE"
fi

# 记录脚本执行完成的时间
echo "$(date): set_crontab.sh ok" >> "$LOG_FILE"
