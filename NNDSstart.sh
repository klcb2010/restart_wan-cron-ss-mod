#!/bin/sh

# Manage log file size
LOG_FILE="/jffs/scripts/startup.log"
MAX_LINES=100
if [ -f "$LOG_FILE" ]; then
    tail -n $MAX_LINES "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

# Set territory code
nvram set territory_code=US/01
nvram commit

# Log success
echo "$(date): NNDSstart.sh executed, territory_code set to US/01" >> "$LOG_FILE"
