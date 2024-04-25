#!/bin/bash
me=$(basename "$0")
IP=$(basename "$1")
ID=$(basename "$2")
HANDLER=$(basename "$3")
ACTION=$(basename "$4")

CHAT_ID=100000000
BOT_TOKEN=6666666666:AABBCCDDEEFFJJetc_Bug


#another approach
#curl "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$CHAT_ID&text=message"

echo $(curl -sS -X POST -H "Content-Type:multipart/form-data" -F chat_id=$CHAT_ID -F text="$ACTION $IP H#$HANDLER for $ID" "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" | sed -e 's/[{}]/''/g' | sed s/\"//g | awk -v RS=',' -F: '$1=="ok"{print $2}')

