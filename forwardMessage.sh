#!/usr/bin/env bash
set -euo pipefail

TELEGRAM_TOKEN="123:ABC..."        #BOT TOKEN
FROM_ID="6741196511"               #SOURCE CHAT ID
DEST_ID="6350100651"               #DEST CHAT ID
START=1                             #FIRST MESSAGE ID (1)
END=250                             #END MESSAGE ID (2)
# -------------------------------

API="https://api.telegram.org/bot${TELEGRAM_TOKEN}"
LOGFILE="forward_log_$(date +%Y%m%d_%H%M%S).log"

echo "Forwarding messages $START..$END from $FROM_ID -> $DEST_ID" | tee "$LOGFILE"

for MSG_ID in $(seq "$START" "$END"); do
  # Perform request and capture response
  resp=$(curl -s -X POST "${API}/forwardMessage" \
    -d chat_id="$DEST_ID" \
    -d from_chat_id="$FROM_ID" \
    -d message_id="$MSG_ID")
  
  if echo "$resp" | grep -q '"ok":true'; then
    echo "$(date -Iseconds) Forwarded message $MSG_ID" | tee -a "$LOGFILE"
  else
    # Print error description if present
    desc=$(echo "$resp" | sed -n 's/.*"description":"\([^"]*\)".*/\1/p' || true)
    echo "$(date -Iseconds) Failed message $MSG_ID : ${desc:-$resp}" | tee -a "$LOGFILE"

    # If rate limited, sleep longer
    if echo "$resp" | grep -q '"error_code":429'; then
      echo "Rate limited; sleeping 10s..." | tee -a "$LOGFILE"
      sleep 10
    else
      # Short delay to avoid spamming
      sleep 0.2
    fi
  fi
done

echo "Done. See $LOGFILE for details."
