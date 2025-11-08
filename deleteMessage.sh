#Notes
  #You can only delete messages that are less than 48 hours old
  #If it is a private chat. You can only delete the bots messages
  
#!/bin/bash

BOT_TOKEN="<YOUR_BOT_TOKEN>"
CHAT_ID="<CHAT_ID>"
LIMIT=500  #Number of messages to delete

#Messages bot has access to
updates=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?limit=$LIMIT")

#Extract message IDs from the updates
message_ids=$(echo "$updates" | jq -r '.result[].message.message_id')

#Loop through each message ID and delete
for msg_id in $message_ids; do
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/deleteMessage" \
         -d "chat_id=$CHAT_ID" \
         -d "message_id=$msg_id"
    echo "Deleted message ID: $msg_id"
done

echo "Deletion attempt complete."
