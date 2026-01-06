#!/bin/sh

LOG_FILE="/jffs/scripts/startup.log"
MAX_LINES=100

# 限制日志大小
if [ -f "$LOG_FILE" ]; then
    tail -n "$MAX_LINES" "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

TARGET="US/01"
CURRENT="$(nvram get territory_code)"

if [ "$CURRENT" != "$TARGET" ]; then
    nvram set territory_code="$TARGET"
    nvram commit
    echo "$(date): territory_code changed from '$CURRENT' to '$TARGET'" >> "$LOG_FILE"
else
    echo "$(date): territory_code already '$TARGET', no change" >> "$LOG_FILE"
fi
