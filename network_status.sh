#!/bin/bash
# Coding by Easy Tec | easytec.tech
# Script suitable for automation every 5-10 minutes cron!
#EXTENDED EDITION
# VERSION: 1.0.0 - BETA
# LANGUAGE: ENGLISH

# Domain name
DOMAIN="http://your.domain.example"

# OAuth API Key
AUTHKEY="your api key"

# Page ID
PAGEID="your page id"

# Component ID
COMPONENTID1="your component id"
COMPONENTID2="your component id"
COMPONENTID3="your component id"
COMPONENTID4="your component id"
COMPONENTID5="your component id"
COMPONENTID6="your component id"

# Component ID of NETWORK Component
COMPONENTID_NETWORK="your component id"


# Variable for Status (FOR DEBUG)
#  0.0   = /// = OK
#    1   = /// = NETWORK DOWN
#    2   = /// = SKRIPT ERROR


#CREATE VARIABLES FOR status AND freeplace
status="0"
freeplace="0"

# ARRAYS
raw_DOMAIN_array=("$DOMAIN")
raw_COMPONENTID_array=("$COMPONENTID1" "$COMPONENTID2" "$COMPONENTID3" "$COMPONENTID4" "$COMPONENTID5" "$COMPONENTID6")
DOMAIN_array=()
COMPONENTID_array=()


for (( ; ; )); do

    domain_status=$(wget --spider -S "${raw_DOMAIN_array[0]}" 2>&1 | grep "HTTP/" | awk '{print $2}')
    domain_status=${domain_status: -3}
    DOMAIN_array[0]="$domain_status"

    #PREVIOUS QUERY
    quest_incident=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/unresolved | cut -c9-20)

    if [[ "${DOMAIN_array[0]}" == "200" ]]; then
        echo "STATUS: OKAY"
        #If there are no errors
        if [[ ! -z "$quest_incident" ]]; then
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X PATCH -d "incident[status]=resolved" -d "incident[components["${COMPONENTID_NETWORK}"]]=operational" -d "incident[components["${COMPONENTID1}"]]=operational" -d "incident[components["${COMPONENTID2}"]]=operational" -d "incident[components["${COMPONENTID3}"]]=operational" -d "incident[components["${COMPONENTID4}"]]=operational" -d "incident[components["${COMPONENTID5}"]]=operational" -d "incident[components["${COMPONENTID6}"]]=operational" -d "incident[body]=NETWORK BACK - automatically generated message" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/"$quest_incident"
        else
            freeplace="1"
        fi
        status="0.0"
        echo "$status" # ONLY FOR DEBUG
        exit 0
    elif [[ ! "$status" == "1" ]]; then
        echo "STATUS: FAILURE"
        #When Errors Exist
        curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=Network outage" -d "incident[status]=investigating" -d "incident[impact_override]=critical" -d "incident[body]=Major Outage - automatically generated message" -d "incident[components["${COMPONENTID_NETWORK}"]]=major_outage" -d "incident[components["${COMPONENTID1}"]]=major_outage" -d "incident[components["${COMPONENTID2}"]]=major_outage" -d "incident[components["${COMPONENTID3}"]]=major_outage" -d "incident[components["${COMPONENTID4}"]]=major_outage" -d "incident[components["${COMPONENTID5}"]]=major_outage" -d "incident[components["${COMPONENTID6}"]]=major_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
        status="1"
        echo "$status" # ONLY FOR DEBUG
        sleep 60
    else
        status="2"
        echo "$status" # ONLY FOR DEBUG
        exit 1
    fi
done
