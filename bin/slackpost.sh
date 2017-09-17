#!/bin/bash

# Take a look at https://dhatim.slack.com/apps/new/A0F7XDUAZ-incoming-webhooks to have your webhook url


usage() {
    cat >&2 <<EOF
Usage: $0 [-c <channel>] [-u <username>] [-i <icon-emoji>] [-w <webhook-url>] <text>

  -c  override the default webhook channel (#chan or @user)
  -u  override the SlackPost default username
  -i  override the :space_invader: default icon
  -w  override the SLACK_WEBHOOK_URL env var
EOF
    exit 1
}

PAYLOAD='payload={'

CHANNEL=""
USERNAME="SlackPost"
ICON=":space_invader:"
WEBHOOK="$SLACK_WEBHOOK_URL"

while getopts ":c:u:i:w:" opt; do
    case $opt in 
        c) CHANNEL=${OPTARG}   ;;
        u) USERNAME=${OPTARG}  ;;
        i) ICON=${OPTARG}      ;;
        w) WEBHOOK=${OPTARG}   ;;
        *) usage                 ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${WEBHOOK}" ] ; then
    echo "No webhook provided"
    usage
fi

if [ -z "$1" ] ; then
    echo "No text provided"
    usage
fi

PAYLOAD=$PAYLOAD'"text":"'$1'"'

if [ -n "$CHANNEL" ] ; then
    PAYLOAD=$PAYLOAD', "channel": "'$CHANNEL'"'
fi

if [ -n "$USERNAME" ] ; then
    PAYLOAD=$PAYLOAD', "username": "'$USERNAME'"'
fi

if [ -n "$ICON" ] ; then
    PAYLOAD=$PAYLOAD', "icon_emoji": "'$ICON'"'
fi

PAYLOAD=$PAYLOAD'}'

curl -s -S -X POST --data-urlencode "$PAYLOAD" "$WEBHOOK" > /dev/null
if [ "$?" -ne "0" ] ; then
    echo -e "Failed to send message"
    exit 2
fi
