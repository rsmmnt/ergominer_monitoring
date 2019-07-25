#!/bin/bash
# This script iterates over mining rigs, sums hashrate from your farm and alerts you about unavailable rigs
# through a Telegram bot
# for Ergo Autolykos GPU miner
# change your rig naming, log file name, telegram bot data and proxy if needed

#PROXY="--socks5 PROXY_ADDR:PROXY_PORT"
PROXY = ""
token=TELEGRAM_BOT_TOKEN
chat_id=CHAT_ID

URL="https://api.telegram.org/bot$token/sendMessage"
echo $token
echo $chat_id
echo $URL

unavail=""
hrtot=0

for i in {01..10}
do

    rig="rig"$i".local"
    hr=$(ssh user@$rig "tail -100 ~/myeasylog.log | grep hashrate | tail -1 | rev | cut -d' ' -f 3 | rev") 
    if [ -z "$hr" ]
    then

        echo "$rig unavailable"
        unavail=$unavail" $rig "

    else

        hrtot=$hrtot+$hr

    fi
done

echo $hrtot 
echo $hrtot | bc > tfile.tmp
total=$(cat tfile.tmp)
echo $total
msg="Current hashrate: "$total" MHs"
echo $msg

rigs="Rigs "$unavail" not available"

curl $PROXY -s -X POST $URL -d chat_id=$chat_id -d text="$msg"

curl $PROXY -s -X POST $URL -d chat_id=$chat_id -d text="$rigs"


