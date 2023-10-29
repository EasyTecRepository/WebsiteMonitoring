#!/bin/bash
#
# Bash script for periodically checking if websites or services are still running,
# to send statuspage / discord / email push notifications in case of failure.
# This script does not support all-clear functions!!! 
# This must ALWAYS be done MANUALLY.
#
# Created by Easy Tec (youtube.com/EasyTec100)
# Instructions see on Github
#
# STATUSPAGE
#

#
# Version 3.0.0
# Version BETA
#

### variables

# What does this script run on? Linux (general) or Unraid?
# Linux: false
# Unraid: true
UNRAID_ENVIRONMENT="false"

# general variables
# Path where the txt file "statuscheck_storage.txt" is located
storage_file_path="error_log.txt"

# Statuspage notifications
# Please select: 1 = yes / 0 = no
statuspage_q=0
# Settings
AUTHKEY="your api key" # OAuth API Key
PAGEID="your page id" # Page ID

# Domain Name Array - Please in the same order as service names and component ID's
DOMAIN_ARRAY=("https://domain.one/" "https://domain.two/" "https://domain.three/" "https://domain.four/")

# Service Name Array - Please in the same order as domain names and component ID's
SERVICE_ARRAY=("DomainOne" "DomainTwo" "DomainThree" "DomainFour")

# Component ID Array - Please in the same order as service names and domain names
COMPONENTID_ARRAY=("012345" "123456" "234567" "345678")

#####

# Discord notifications
# Please select: 1 = yes / 0 = no
discord_q=0
# Settings
WEBHOOK="your webhook url" #Webhook
DISCORD_USERNAME="your author name" #Username
DISCORD_AVATAR_URL="your avatar url" #Avatar url
DISCORD_ERROR_TITLE="MAJOR OUTAGE REPORTED!" #Major Outage
DISCORD_OKAY_TITLE="ALL NORMAL" #Operational
DISCORD_FAILURE_TITLE="PARTIAL OUTAGE REPORTED!" #Partial Outage
DISCORD_DEGRADED_TITLE="DEGRADED PERFORMANCE REPORTED!" #Degraded Performance
DISCORD_MAINTENANCE_TITLE="MAINTENANCE REPORTED!" #Maintenance
DISCORD_ACTION_TITLE="HUMAN ACTION REQUIRED!" #Action required
DISCORD_ERROR_COLOR="0xf41100" #Major Outage
DISCORD_FAILURE_COLOR="0xffff00" #Partial Outage
DISCORD_OKAY_COLOR="0x13de10" #Operational
DISCORD_DEGRADED_COLOR="0xffff00" #Degraded Performance
DISCORD_MAINTENANCE_COLOR="0x03b2f8" #Maintenance
DISCORD_ACTION_COLOR="0xffff00" #Action
DISCORD_AUTHOR="your author name" #Author
DISCORD_AUTHOR_URL="url of your statuspage" #Author url
DISCORD_AUTHOR_ICON="url of your author picture" #Author url
DISCORD_ACTION_THUMBNAIL="url of your action picture" #Action Required icon
DISCORD_ERROR_THUMBNAIL="url of your major outage picture" #Major Outage autor icon
DISCORD_OKAY_THUMBNAIL="url of your operational picture" #Operational autor icon
DISCORD_MAINTENANCE_THUMBNAIL="url of your maintenance picture" #Maintenance autor icon
DISCORD_FAILURE_THUMBNAIL="url of your partial outage picture" #Partial Outage autor icon
DISCORD_SH_LOCATION="/boot/config/plugins/user.scripts/scripts/discord.sh" #Path of your Discord.sh script

# E-Mails
# Please select: 1 = yes / 0 = no
email_q=0
SMTPFROM="mail@example.com"
SMTPTO=("mail1@example.com" "mail2@example.com")
SMTPSERVER="smtp.googlemail.com"
SMTPPORT="587"
SMTPUSER="mail@example.com"
SMTPPASS="a1b2c3d4e5f6g7"
mailscript_path_fault="/path/to/script/script.py" # E-mail for fault

## HTTP status code text ##
# general
# 200 = website is available
# 000 = website is unavailable
# ??? / non-official code = Not officially defined by a standard
# 200
http200="OK" #200
# 4xx
http400="BAD REQUEST" #400
http401="UNAUTHORIZED" #401
http402="PAYMENT REQUIRED" #402
http403="FORBIDDEN" #403
http404="NOT FOUND" #404
http405="METHOD NOT ALLOWED" #405
http406="NOT ACCEPTABLE" #406
http407="PROXY AUTHENTICATION REQUIRED" #407
http408="REQUEST TIMEOUT" #408
http409="CONFLICT" #409
http410="GONE" #410
http411="LENGTH REQUIRED" #411
http412="PRECONDITION FAILED" #412
http413="PAYLOAD TOO LARGE" #413
http414="URI TOO LONG" #414
http415="UNSUPPORTED MEDIA TYPE" #415
http416="RANGE NOT SATISFIABLE" #416
http417="EXPECTATION FAILED" #417
http418="I'M A TEAPOT" #418
http421="MISDIRECTED REQUEST" #421
http422="UNPROCESSABLE ENITITY" #422
http423="LOCKED" #423
http424="FAILED DEPENDENCY" #424
http425="TOO EARLY" #425
http426="UPGRADE REQUIRED" #426
http428="PRECONDITION REQUIRED" #428
http429="TOO MANY REQUESTS" #429
http431="REQUEST HEADER FIELDS TOO LARGE" #431
http451="UNAVAILIBLE FOR LEGAL REASONS" #451
# 5xx
http500="INTERNAL SERVER ERROR" #500
http501="NOT IMPLEMENTED" #501
http502="BAD GATEWAY" #502
http503="SERVICE UNAVAILIBLE" #503
http504="GATEWAY TIMEOUT" #504
http505="HTTP VERSION NOT SUPPORTED" #505
http506="VARIANT ALSO NEGOTIATES" #506
http507="INSUFFICIENT STORAGE" #507
http508="LOOP DETECTED" #508
http510="NOT EXTENDED" #510
http511="NETWORK AUTHENTICATION REQUEST" #511

### FROM HERE PLEASE DO NOT MAKE ANY CHANGES ###

# COLORS
if [[ "$UNRAID_ENVIRONMENT" == "true" ]]; then
    # use Unraid
    GREEN="<font color='green'>"
    RED="<font color='red'>"
    BLUE="<font color='blue'>"
    ORANGE="<font color='orange'>"
    PURPLE="<font color='purple'>"
    CLOSER="</font>"
else
    # use another linux
    GREEN="\033[0;32m"
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    ORANGE='\033[0;33m'
    PURPLE="\033[0;35m"
    CLOSER="\033[0m"
fi

# Variable to track the status of the sites
all_reachable=true

# Function for different messages depending on status code
check_status() {
    local code=$1

    case $code in
        200)
            echo 1
            ;;
        0)
            echo 2
            ;;
        400 | 401 | 402 | 403 | 404 | 405 | 406 | 407 | 408 | 409 | 410 | 411 | 412 | 413 | 414 | 415 | 416 | 417 | 418 | 421 | 422 | 423 | 424 | 425 | 426 | 428 | 429 | 431 | 451)
            echo 3
            ;;
        500 | 501 | 502 | 503 | 504 | 505 | 506 | 507 | 508 | 510 | 511)
            echo 4
            ;;
        *)
            echo 0
            ;;
    esac
}

# Function to delete the entire contents of the error log file
clear_error_log() {
    : > "$storage_file_path"
    echo -e "${PURPLE}All errors have been fixed. The error log has been cleared.${CLOSER}"
}

# Loop over each site in the array for status check
for ((i = 0; i < ${#DOMAIN_ARRAY[@]}; i++))
do
    # Get HTTP status code, ignoring redirects
    http_status_code=$(curl -L -s -o /dev/null -w "%{http_code}" "${DOMAIN_ARRAY[$i]}")

    httpCodeMean="http${http_status_code}" # Defines meaning of HTTP status code

    if [ "$http_status_code" -ne 200 ]; then
        all_reachable=false
    fi

    # Calling the function and saving the return value
    result=$(check_status "$http_status_code")

    site="${DOMAIN_ARRAY[$i]}"
    # Check if the error has already been reported
    if grep -q "$site" "$storage_file_path"; then
        echo -e "${BLUE}NOTE: ${SERVICE_ARRAY[$i]} - Already reported (Statuscode: $http_status_code - ${!httpCodeMean})${CLOSER}"
    # Check if the JSON response contains the keyword for planned maintenance status
    elif [[ statuspage_q -eq 1 ]] && [ "$(curl --silent -H "Authorization: OAuth ${AUTHKEY}" -X GET "https://api.statuspage.io/v1/pages/$PAGEID/components/${COMPONENTID_ARRAY[$i]}" | jq -r '.status')" != "null" ] && [ "$(curl --silent -H "Authorization: OAuth ${AUTHKEY}" -X GET "https://api.statuspage.io/v1/pages/$PAGEID/components/${COMPONENTID_ARRAY[$i]}" | jq -r '.status')" == "under_maintenance" ]; then
        # Maintenance active
        echo "${BLUE}NOTE: Active maintenance mode at ${SERVICE_ARRAY[$i]}. Already reported error.${CLOSER}"
    else
        # Checking the return value and handling it accordingly
        case $result in
            
            1) echo -e "${GREEN}Service: ${SERVICE_ARRAY[$i]} | Domain: ${DOMAIN_ARRAY[$i]} | HTTP status: $http_status_code - ${!httpCodeMean} | reachable${CLOSER}"
               # 200
               # Idea: In the future you may be able to disarm via a Discord bot...
               echo "Human action required: All created incidents must be manually defused."
               if [[ $discord_q -eq 1 ]]; then sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_ACTION_TITLE" --description "All created incidents must be manually defused." --color "$DISCORD_ACTION_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_ACTION_THUMBNAIL" --footer "automatically generated message" --timestamp; fi; fi
               #if [[ $statuspage_q -eq 1 ]]; then  ; fi
               #if [[ $email_q -eq 1 ]]; then  ; fi
               ;;
            2) echo -e "${RED}Service: ${SERVICE_ARRAY[$i]} | Domain: ${DOMAIN_ARRAY[$i]} | HTTP status: $http_status_code - ${!httpCodeMean} | Connection Refused${CLOSER}"
               # unreachable
               echo "${DOMAIN_ARRAY[$i]}" >> "$storage_file_path" # Adding the URL to the error log
               if [[ $discord_q -eq 1 ]]; then sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_ERROR_TITLE" --description "Service(s) affected: "${SERVICE_ARRAY[$i]}"" --color "$DISCORD_ERROR_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_ERROR_THUMBNAIL" --field "CURRENT STATUS: $http_status_code - ${!httpCodeMean}" --footer "automatically generated message" --timestamp; fi
               if [[ $statuspage_q -eq 1 ]]; then curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=critical" -d "incident[body]=page not available - automatically generated message" -d "incident[components["${COMPONENTID_ARRAY[$i]}"]]=major_outage" -d "incident[component_ids]="${COMPONENTID_ARRAY[$i]}"" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents; fi
               if [[ $email_q -eq 1 ]]; then for recipient in "${SMTPTO[@]}"; do python3 "$mailscript_path_fault" "$SMTPFROM" "$recipients_string" "$SMTPSERVER" "$SMTPPORT" "$SMTPUSER" "$SMTPPASS"; done ; fi
               ;;
            3) echo -e "${ORANGE}Service: ${SERVICE_ARRAY[$i]} | Domain: ${DOMAIN_ARRAY[$i]} | HTTP status: $http_status_code - ${!httpCodeMean} | unreachable${CLOSER}"
               # 4xx
               echo "${DOMAIN_ARRAY[$i]}" >> "$storage_file_path" # Adding the URL to the error log
               if [[ $discord_q -eq 1 ]]; then sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_FAILURE_TITLE" --description "Service(s) affected: "${SERVICE_ARRAY[$i]}"" --color "$DISCORD_FAILURE_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_FAILURE_THUMBNAIL" --field "CURRENT STATUS: $http_status_code - ${!httpCodeMean}" --footer "automatically generated message" --timestamp; fi
               if [[ $statuspage_q -eq 1 ]]; then curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]="$http_status_code" - "${!httpCodeMean}" error - automatically generated message" -d "incident[components["${COMPONENTID_ARRAY[$i]}"]]=partial_outage" -d "incident[component_ids]="${COMPONENTID_ARRAY[$i]}"" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents ; fi
               if [[ $email_q -eq 1 ]]; then for recipient in "${SMTPTO[@]}"; do python3 "$mailscript_path_fault" "$SMTPFROM" "$recipients_string" "$SMTPSERVER" "$SMTPPORT" "$SMTPUSER" "$SMTPPASS"; done ; fi
               ;;
            4) echo -e "${ORANGE}Service: ${SERVICE_ARRAY[$i]} | Domain: ${DOMAIN_ARRAY[$i]} | HTTP status: $http_status_code - ${!httpCodeMean} | unreachable${CLOSER}"
               # 5xx
               echo "${DOMAIN_ARRAY[$i]}" >> "$storage_file_path" # Adding the URL to the error log
               if [[ $discord_q -eq 1 ]]; then sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_FAILURE_TITLE" --description "Service(s) affected: "${SERVICE_ARRAY[$i]}"" --color "$DISCORD_FAILURE_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_FAILURE_THUMBNAIL" --field "CURRENT STATUS: $http_status_code - ${!httpCodeMean}" --footer "automatically generated message" --timestamp; fi
               if [[ $statuspage_q -eq 1 ]]; then curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]="$http_status_code" - "${!httpCodeMean}" error - automatically generated message" -d "incident[components["${COMPONENTID_ARRAY[$i]}"]]=partial_outage" -d "incident[component_ids]="${COMPONENTID_ARRAY[$i]}"" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents ; fi
               if [[ $email_q -eq 1 ]]; then for recipient in "${SMTPTO[@]}"; do python3 "$mailscript_path_fault" "$SMTPFROM" "$recipients_string" "$SMTPSERVER" "$SMTPPORT" "$SMTPUSER" "$SMTPPASS"; done ; fi
               ;;
            *) echo -e "${ORANGE}Service: ${SERVICE_ARRAY[$i]} | Domain: ${DOMAIN_ARRAY[$i]} | HTTP status: $http_status_code - ${!httpCodeMean} | unexpected${CLOSER}"
               # unexpected values
               echo "${DOMAIN_ARRAY[$i]}" >> "$storage_file_path" # Adding the URL to the error log
               if [[ $discord_q -eq 1 ]]; then sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_FAILURE_TITLE" --description "Service(s) affected: "${SERVICE_ARRAY[$i]}"" --color "$DISCORD_FAILURE_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_FAILURE_THUMBNAIL" --field "CURRENT STATUS: $http_status_code - maybe unknown" --footer "automatically generated message" --timestamp; fi
               if [[ $statuspage_q -eq 1 ]]; then curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]="$http_status_code" - maybe unknown error - automatically generated message" -d "incident[components["${COMPONENTID_ARRAY[$i]}"]]=partial_outage" -d "incident[component_ids]="${COMPONENTID_ARRAY[$i]}"" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents ; fi
               if [[ $email_q -eq 1 ]]; then for recipient in "${SMTPTO[@]}"; do python3 "$mailscript_path_fault" "$SMTPFROM" "$recipients_string" "$SMTPSERVER" "$SMTPPORT" "$SMTPUSER" "$SMTPPASS"; done ; fi
               ;;
        esac
    fi
done

# Check if all websites are reachable and clear the error log
if $all_reachable; then
    clear_error_log
else
    echo -e "${PURPLE}Not all websites are reachable. The error log remains unchanged.${CLOSER}"
fi
