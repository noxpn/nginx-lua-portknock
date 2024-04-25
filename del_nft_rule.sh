#!/bin/bash
me=$(basename "$0")
IP=$(basename "$1")
ID=$(basename "$2")
HANDLER=$(basename "$3")

FILTER_FAMILY=inet
FILTER_TABLE=filter
FILTER_CHAIN=tmp

ACTION="CLOSE"

logger -t "$me" "flush rules #$ID"

sudo nft flush chain $FILTER_FAMILY $FILTER_TABLE $FILTER_CHAIN
TG_RESP=$(/etc/nginx/lua/tg_send.sh $IP $ID $HANDLER $ACTION)

echo $TG_RESP
