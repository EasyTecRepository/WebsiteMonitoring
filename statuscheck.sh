#!/bin/bash
#
# Bash script for periodically checking if websites or services are still running, 
# to send status page push notifications in case of failure. 
#
# Created by Easy Tec (youtube.com/EasyTec100)
# Instructions see on Github
#
# STATUSPAGE
#

#
# Version 1.0.0
# Version BETA
#

### variables

# Statuspage notifications
# Please select: 1 = yes / 0 = no
statuspage_q=1
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
discord_q=1
# Settings
WEBHOOK="your webhook url" #Webhook
DISCORD_USERNAME="your author name" #Username
DISCORD_AVATAR_URL="your avatar url" #Avatar url
DISCORD_ERROR_TITLE="MAJOR OUTAGE REPORTED!" #Major Outage
DISCORD_OKAY_TITLE="ALL NORMAL" #Operational
DISCORD_FAILURE_TITLE="PARTIAL OUTAGE REPORTED!" #Partial Outage
DISCORD_DEGRADED_TITLE="DEGRADED PERFORMANCE REPORTED!" #Degraded Performance
DISCORD_MAINTENANCE_TITLE="MAINTENANCE REPORTED!" #Maintenance
DISCORD_ERROR_COLOR="0xf41100" #Major Outage
DISCORD_FAILURE_COLOR="0xffff00" #Partial Outage
DISCORD_OKAY_COLOR="0x13de10" #Operational
DISCORD_DEGRADED_COLOR="0xffff00" #Degraded Performance
DISCORD_MAINTENANCE_COLOR="0x03b2f8" #Maintenance
DISCORD_AUTHOR="your author name" #Author
DISCORD_AUTHOR_URL="url of your statuspage" #Author url
DISCORD_AUTHOR_ICON="url of your author picture" #Author url
DISCORD_ERROR_THUMBNAIL="url of your major outage picture" #Major Outage autor icon
DISCORD_OKAY_THUMBNAIL="url of your operational picture" #Operational autor icon
DISCORD_MAINTENANCE_THUMBNAIL="url of your maintenance picture" #Maintenance autor icon
DISCORD_FAILURE_THUMBNAIL="url of your partial outage picture" #Partial Outage autor icon
DISCORD_SH_LOCATION="/boot/config/plugins/user.scripts/scripts/discord.sh" #Path of your Discord.sh script

# E-Mails
# Please select: 1 = yes / 0 = no
email_q=0
SMTPFORM="mail@example.com"
SMTPTO="mail@example.com"
SMTPSERVER="smtp.googlemail.com:587"
SMTPUSER="mail@example.com"
SMTPPASS="a1b2c3d4e5f6g7"
mailscript_path="/path/to/script/script.py"

## HTTP status code text ##
# general
# 200 = website is available
# 000 = website is unavailable
# ??? / non-official code = Not officially defined by a standard
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

excluded_statuscodes_4xx=(419 420 427 430 432 433 434 435 436 437 438 439 440 441 442 443 444 445 446 447 448 449 450) # Array of excluded 4xx statuscodes
excluded_statuscodes_5xx=(509) # Array of excluded 5xx statuscodes

### FROM HERE PLEASE DO NOT MAKE ANY CHANGES ###

# Check Status
if [[ statuspage_q -eq 1 ]]; then
    count_domain_status=${#DOMAIN_ARRAY[@]} # Get the number of domains in the array
    http_status_codes=() # Array for HTTP statuscodes
    COMPONENTID_ARRAY_AFFECTED=() # Array for affected ComponentID'S
    # Loop for HTTP status request
    for ((i = 0; i < count_domain_status; i++)); do
        domain="${DOMAIN_ARRAY[i]}"
        service="${SERVICE_ARRAY[i]}"
        http_status=$(curl -s -o /dev/null -w "%{http_code}" -L "$domain")
        http_status_codes+=("$http_status")
    done
    for ((i = 0; i < count_domain_status; i++)); do
        #
        if [ "${http_status[$i]}" -ne 200 ]; then
            COMPONENTID_ARRAY_AFFECTED+=("$COMPONENTID_ARRAY[i]")
            # http status not 200
            # Check if the JSON response contains the keyword for planned maintenance status
            if [ $(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET "https://api.statuspage.io/v1/pages/$PAGEID/components/$COMPONENTID_ARRAY[$i]" | jq -r '.status') ]; then
                # Maintenance active
                echo "Note: Active maintenance mode at ${service[$i]}. Already reported error."
            else
                # Maintenance not active
                echo "Note: No active maintenance mode at ${service[$i]}. This means that it is probably an unreported error."
                # Check if the JSON response contains the keyword for problems (incident)
                if [ $(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET "https://api.statuspage.io/v1/pages/$PAGEID/incidents/unresolved" | jq -r '.[0].components[0].status') != "null" ]; then
                    # Incident already created
                    echo "Incident already present for ${service[$i]}. No action required."
                    echo "Domain: ${domain[$i]} | HTTP status: ${http_status[$i]} | unavailable"
                    echo
                else
                    # Incident not created yet
                    echo "Incident not present for ${service[$i]}. Will be created."
                    incidentID=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/unresolved | jq -r '.[0].id')
                    if [ -z "${http_status[$i]}" ]; then
                        httpCodeCurrent="http${http_status[$i]}" # Define current http status code query
                        # Empty (000)
                        echo "Service: ${service[$i]} | Domain: ${domain[$i]} | HTTP status: ${http_status[$i]}
                        if [[ statuspage_q -eq 1 ]]; then
                            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=critical" -d "incident[body]=page not available - automatically generated message" -d "incident[components["${COMPONENTID_ARRAY[$i]}"]]=major_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
                        fi
                        if [[ discord_q -eq 1 ]]; then
                        sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_ERROR_TITLE" --description "Service(s) affected: "${service[$i]}"" --color "$DISCORD_ERROR_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_ERROR_THUMBNAIL" --field "CURRENT STATUS:;"${http_status[$i]}" - "$httpCodeCurrent"" --footer "automatically generated message" --timestamp
                        fi
                        if [[ email_q -eq 1 ]]; then
                            bash $mailscript_path "$SMTPFORM" "$SMTPTO" "$SMTPSERVER" "$SMTPUSER" "$SMTPPASS"
                        fi
                        echo
                    elif [ "${http_status[$i]}" -ge 400 ] && [ "${http_status[$i]}" -le 451 ] && [[ " ${excluded_statuscodes_4xx[@]} " =~ " ${http_status[$i]} " ]]; then
                        # 4xx
                        echo "Service: ${service[$i]} | Domain: ${domain[$i]} | HTTP status: ${http_status[$i]}
                        if [[ statuspage_q -eq 1 ]]; then
                            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]="${http_status[$i]}" - "$httpCodeCurrent" error - automatically generated message" -d "incident[components["${COMPONENTID_ARRAY[$i]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
                        fi
                        if [[ discord_q -eq 1 ]]; then
                            sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_ERROR_TITLE" --description "Service(s) affected: "${service[$i]}"" --color "$DISCORD_FAILURE_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_FAILURE_THUMBNAIL" --field "CURRENT STATUS:;"${http_status[$i]}" - "$httpCodeCurrent"" --footer "automatically generated message" --timestamp
                        fi
                        if [[ email_q -eq 1 ]]; then
                            bash $mailscript_path "$SMTPFORM" "$SMTPTO" "$SMTPSERVER" "$SMTPUSER" "$SMTPPASS"
                        fi
                        echo
                    elif [ "${http_status[$i]}" -ge 500 ] && [ "${http_status[$i]}" -le 511 ] && [[ " ${excluded_statuscodes_5xx[@]} " =~ " ${http_status[$i]} " ]]; then
                        # 5xx
                        echo "Service: ${service[$i]} | Domain: ${domain[$i]} | HTTP status: ${http_status[$i]}"
                        if [[ statuspage_q -eq 1 ]]; then
                            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]="${http_status[$i]}" - "$httpCodeCurrent" error - automatically generated message" -d "incident[components["${COMPONENTID_ARRAY[$i]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
                        fi
                        if [[ discord_q -eq 1 ]]; then
                            sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_ERROR_TITLE" --description "Service(s) affected: "${service[$i]}"" --color "$DISCORD_FAILURE_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_FAILURE_THUMBNAIL" --field "CURRENT STATUS:;"${http_status[$i]}" - "$httpCodeCurrent"" --footer "automatically generated message" --timestamp
                        fi
                        if [[ email_q -eq 1 ]]; then
                            bash $mailscript_path "$SMTPFORM" "$SMTPTO" "$SMTPSERVER" "$SMTPUSER" "$SMTPPASS"
                        fi
                        echo
                    else
                        # non-official code
                        echo "Service: ${service[$i]} | Domain: ${domain[$i]} | HTTP status: ${http_status[$i]}"
                        if [[ statuspage_q -eq 1 ]]; then
                            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]="${http_status[$i]}" - non-official code - automatically generated message" -d "incident[components["${COMPONENTID_ARRAY[$i]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
                        fi
                        if [[ discord_q -eq 1 ]]; then
                            sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_ERROR_TITLE" --description "Service(s) affected: "${service[$i]}"" --color "$DISCORD_FAILURE_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_FAILURE_THUMBNAIL" --field "CURRENT STATUS:;"${http_status[$i]}" - non-official code" --footer "automatically generated message" --timestamp
                        fi
                        if [[ email_q -eq 1 ]]; then
                            bash $mailscript_path "$SMTPFORM" "$SMTPTO" "$SMTPSERVER" "$SMTPUSER" "$SMTPPASS"
                        fi
                        echo
                fi
            fi
        else
            # http status is 200
            echo "Service: ${service[$i]} | Domain: ${domain[$i]} | HTTP status: ${http_status[$i]} | available"
            ###
            if [[ " ${http_status_codes[@]} " =~ " 200 " ]]; then # Check if any service has a different status than 200
                incidentID=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/unresolved | jq -r '.[0].id')
                if [ ! -z "$incidentID" ]; then
                    # Close incident as there is no longer a problem
                    curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X PATCH -d "incident[status]=resolved" -d "incident[components["${COMPONENTID_ARRAY}"]]=operational" -d "incident[body]=page now available - automatically generated message" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/"$incidentID"
                    sudo bash "$DISCORD_SH_LOCATION" --webhook-url="$WEBHOOK" --username "$DISCORD_USERNAME" --avatar "$DISCORD_AVATAR_URL" --title "$DISCORD_OKAY_TITLE" --description "Service(s) affected: "${array_REPORTED_WEBSITES[$schleife]}"" --color "$DISCORD_OKAY_COLOR" --author "$DISCORD_AUTHOR" --author-url "$DISCORD_AUTHOR_URL" --author-icon "$DISCORD_AUTHOR_ICON" --thumbnail "$DISCORD_OKAY_THUMBNAIL" --field "CURRENT STATUS:;"${http_status[$i]}" --footer "automatically generated message" --timestamp
                fi
            fi
        fi
    done
fi
