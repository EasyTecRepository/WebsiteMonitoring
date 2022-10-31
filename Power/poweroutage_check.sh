#!/bin/bash
# Coding by Easy Tec | easytec.tech
# Script suitable for automation every 5-10 minutes cron!
# POWER SCRIPT
# VERSION: 1.0.0 - BETA
# LANGUAGE: ENGLISH

# OAuth API Key
AUTHKEY="your api key"

# Page ID
PAGEID="your page id"

# Component ID of Power (Component)
COMPONENTID_master="your component id"

# Component ID (in the event of a prolonged power failure, these are set to degraded performance)
COMPONENTID1="your component id"
COMPONENTID2="your component id"
COMPONENTID3="your component id"
COMPONENTID4="your component id"
COMPONENTID5="your component id"
COMPONENTID6="your component id"
COMPONENTID7="your component id"

# Log Path/Location - (default: /mnt/user/statuspage_power/CURRENT_UPS_STATUS.txt)
log_path=""

### DO NOT ADJUST ANYTHING FROM THIS POINT ON! - (Unless you want to take the risk) ###

# Set array
raw_COMPONENTID_array=("$COMPONENTID1" "$COMPONENTID2" "$COMPONENTID3" "$COMPONENTID4" "$COMPONENTID5" "$COMPONENTID6" "$COMPONENTID7")

#DEBUG
debug="0"
# 0 = OKAY
# 1 = SYSTEM ONLINE; OKAY
# 2 = SCRIPT ERROR
# 3 = NOTHING APPLIES

# Pull UPS status
UPS_STATUS=$(sudo tail -n 1 "${log_path}")
UPS_STATUS_secound=$(sudo tail -n 2 "${log_path}" | sed -n "1p")
# QUERY: ERROR EXIST..?
quest_incident=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/unresolved | cut -c9-20)


if [[ "$UPS_STATUS" == "Online" ]] && [ -z "$quest_incident" ]; then
    debug="1" #set debug
    #echo "okay - nothing"#ONLY FOR DEBUG
elif [[ "$UPS_STATUS" == *"On battery"* ]] && [ -z "$quest_incident" ] && [[ ! "$UPS_STATUS_secound" == *"On battery"* ]]; then
    curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=Power failure" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=Power failure - automatically generated message" -d "incident[components["${COMPONENTID_master}"]]=major_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
    #echo "okay - Power failure"#ONLY FOR DEBUG
elif [[ "$UPS_STATUS" == *"0"* ]] || [ -z "$quest_incident" ] && [[ ! "$UPS_STATUS_secound" == *"0"* ]]; then
    curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=Query error" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=Query error of the script - automatically generated message" -d "incident[components["${COMPONENTID_master}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
    #echo "error - Query error of the script"#ONLY FOR DEBUG
elif [[ "$UPS_STATUS" == *"Online"* ]] && [ ! -z "$quest_incident" ] && [[ ! "$UPS_STATUS_secound" == *"Online"* ]]; then
    curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X PATCH -d "incident[status]=resolved" -d "incident[components["${COMPONENTID_master}"]]=operational" -d "incident[body]=Power supply has returned / Error fixed - automatically generated message" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/"$quest_incident"
    #echo "okay - Power supply has returned / Error fixed"#ONLY FOR DEBUG
elif [ -z "$quest_incident" ]; then
    debug="2" #set debug
    curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown error" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=unknown script error - automatically generated message" -d "incident[components["${COMPONENTID_master}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
    #echo "error - unknown error - Invalid/wrong API key?"#ONLY FOR DEBUG
    exit 1
else
    debug="3" #set debug
fi

SECONDS=0 #SET TIME
WAIT="6000" #SET WAIT TIME (default: 6000 => 100minutes)
if [ $SECONDS > $WAIT ] && [[ "$UPS_STATUS" == *"On battery"* ]]; then #question how long power outage already lasts
    curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X PATCH -d "incident[status]=investigating" -d "incident[impact_override]=major" -d "incident[body]=Power outage for over 2 hours! - automatically generated message" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/"$quest_incident"
    for loop in {0..6}; do
        curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X PATCH -d "component[status]=degraded_performance" https://api.statuspage.io/v1/pages/"${PAGEID}"/components/"${raw_COMPONENTID_array[$loop]}"
    done
else
    #echo "Not longer than "$WAIT" secounds"#ONLY FOR DEBUG
    debug="1" #set debug
fi
