#!/bin/bash
me=$(basename "$0")
IP=$(basename "$1")
ID=$(basename "$2")

FILTER_FAMILY=inet
FILTER_TABLE=filter
FILTER_CHAIN=tmp

ACTION="OPEN"

logger -t "$me" "knock: $ID #$ID"

sudo /usr/sbin/nft add chain $FILTER_FAMILY $FILTER_TABLE $FILTER_CHAIN
sudo /usr/sbin/nft insert rule $FILTER_FAMILY $FILTER_TABLE $FILTER_CHAIN ip saddr $IP tcp dport 443 ct state new counter accept comment \"$ID \"
HANDLER=$(sudo /usr/sbin/nft -a list chain $FILTER_FAMILY $FILTER_TABLE $FILTER_CHAIN | awk "/$ID .* # handle [0-9]+/ {gsub(/\\n$/, \"\", \$NF); print \$NF}")
TG_RESP=$(/etc/nginx/lua/tg_send.sh $IP $ID $HANDLER $ACTION) 

echo $HANDLER $TG_RESP

