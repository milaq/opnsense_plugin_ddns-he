#!/usr/local/bin/bash
#
# Dynamic DNS udpater for OPNsense cron
#
# Copyright (c) 2022 milaq <micha.laqua@gmail.com>
#
# This belongs into /usr/local/bin/ddns-he.sh

API_ENDPOINT="https://dyn.dns.he.net/nic/update"
API_TIMEOUT_SECS=30
LOG_TAG="ddns-he"

log () {
  echo "$1: $2"
  logger -p "user.$1" -t "$LOG_TAG" "$2"
}

if [[ -z $1 ]]; then
  log "error" "Missing domain"
  exit 1
fi
if [[ -z $2 ]]; then
  log "error" "Missing API key"
  exit 1
fi

res=$(timeout $API_TIMEOUT_SECS curl -s "$API_ENDPOINT" -d "hostname=$1" -d "password=$2")
if [[ $? -ne 0 ]]; then
  res="apifail"
fi

if [[ "$res" == good* ]]; then
  log "notice" "Successfully updated DNS entry for $1"
  exit 0
elif [[ "$res" == nochg* ]]; then
  exit 0
else
  log "error" "Error updating dynamic DNS entry for $1: $res"
  exit 1
fi
