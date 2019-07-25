#!/bin/bash
# This script iterates over rigs and sends all mined solutions data
# through a Telegram bot
# for Ergo Autolykos GPU miner
# change your rig naming, log file name, telegram bot data and proxy if needed

#PROXY="--socks5 PROXY_ADDR:PROXY_PORT"
PROXY = ""
token=TELEGRAM_BOT_TOKEN
chat_id=CHAT_ID

msg="Latest blocks:\n"

URL="https://api.telegram.org/bot$token/sendMessage"
echo $token
echo $chat_id
echo $URL

curl $PROXY -s -X POST $URL -d chat_id=$chat_id -d text="Latest blocks: "

for i in {01..10}
do
    rig="rig"$i".local"
    echo $rig
    a=$(ssh user@$rig 'tail -2000 ~/myeasylog.log | grep -A 5 found') 
    if [ -z "$a" ]
    then

        echo "No sols"

    else

        curl $PROXY -s -X POST $URL -d chat_id=$chat_id -d text="$a"

    fi

done


