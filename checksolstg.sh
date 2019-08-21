#!/bin/bash
# This script iterates over rigs and sends all mined solutions data
# through a Telegram bot
# also checks if mined block is present in block explorer via API
# it can help identifying problems with your Ergo node
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

        printf "$a" > tmp.txt
        hex=$(cat tmp.txt | grep 'd =' | tail -1 | cut -c14- | sed 's/ //g')
        curl $PROXY -s -X POST $URL -d chat_id=$chat_id -d text="$a"
        #convert hex D to decimal D
        blockid=$(echo "ibase=16;$hex" | bc)
        #check if block with this D is found in explorer
        curl https://api.ergoplatform.com/blocks/byD/$blockid > tmp.txt
        bhash=$(cat tmp.txt | awk -F'\"' '{print $8;}')
        if [ -z "$bhash" ]
        then
            curl $PROXY -s -X POST $URL -d chat_id=$chat_id -d text="Something went wrong, cannot find block in the explorer"
        else
            curl $PROXY -s -X POST $URL -d chat_id=$chat_id -d text="https://explorer.ergoplatform.com/en/blocks/$bhash"
        fi
    fi

done
