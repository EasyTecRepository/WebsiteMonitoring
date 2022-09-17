#!/bin/bash
# Coding by Easy Tec | easytec.tech
# Script suitable for automation every 5-10 minutes cron!
#EXTENDED EDITION
# VERSION: 1.0.0 - BETA
# LANGUAGE: ENGLISH

# Domain name
DOMAIN1="http://your.domain.example"
DOMAIN2="http://your.domain.example"
DOMAIN3="http://your.domain.example"
DOMAIN4="http://your.domain.example"
DOMAIN5="http://your.domain.example"
DOMAIN6="http://your.domain.example"

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


# Variable for Status (FOR DEBUG)
#  0.1   = /// = ERROR FIXED
#  0.5   = /// = Existing incident without website error was resolved (forced)
#    0   = 200 = OK
#    1   = --- = FAILED
#    2   = 503 = MAINTENANCE
#    3   = ??? = UNKNOWN ERRORCODE
#   4.1  = 400 = BAD REQUEST
#   4.2  = 401 = UNAUTHORIZED
#   4.3  = 402 = PAYMENT REQUIRED
#   4.4  = 403 = FORBIDDEN
#   4.5  = 404 = NOT FOUND
#   4.6  = 405 = METHOD NOT ALLOWED
#   4.7  = 406 = NOT ACCEPTABLE
#   4.8  = 407 = PROXY AUTHENTICATION REQUIRED
#   4.9  = 408 = REQUEST TIMEOUT
#  4.10  = 409 = CONFLICT
#  4.11  = 410 = GONE
#  4.12  = 411 = LENGTH REQUIRED
#  4.13  = 412 = PRECONDITION FAILED
#  4.14  = 413 = PAYLOAD TOO LARGE
#  4.15  = 414 = URI TOO LONG
#  4.16  = 415 = UNSUPPORTED MEDIA TYPE
#  4.17  = 416 = RANGE NOT SATISFIABLE
#  4.18  = 417 = EXPECTATION FAILED
#  4.19  = 418 = I'M A TEAPOT
#  4.20  = 421 = MISDIRECTED REQUEST
#  4.21  = 422 = UNPROCESSABLE ENITITY
#  4.22  = 423 = LOCKED
#  4.23  = 424 = FAILED DEPENDENCY
#  4.24  = 425 = TOO EARLY
#  4.25  = 426 = UPGRADE REQUIRED
#  4.26  = 428 = PRECONDITION REQUIRED
#  4.27  = 429 = TOO MANY REQUESTS
#  4.28  = 431 = REQUEST HEADER FIELDS TOO LARGE
#  4.29  = 451 = UNAVAILIBLE FOR LEGAL REASONS
#  5.1   = 500 = INTERNAL SERVER ERROR
#  5.2   = 501 = NOT IMPLEMENTED
#  5.3   = 502 = BAD GATEWAY
#  5.4   = 503 = SERVICE UNAVAILIBLE
#  5.5   = 504 = GATEWAY TIMEOUT
#  5.6   = 505 = HTTP VERSION NOT SUPPORTED
#  5.7   = 506 = VARIANT ALSO NEGOTIATES
#  5.8   = 507 = INSUFFICIENT STORAGE
#  5.9   = 508 = LOOP DETECTED
#  5.10  = 510 = NOT EXTENDED
#  5.11  = 511 = NETWORK AUTHENTICATION REQUEST

#CREATE VARIABLES FOR status AND freeplace
status="0"
freeplace="0"

# ARRAYS
raw_DOMAIN_array=("$DOMAIN1" "$DOMAIN2" "$DOMAIN3" "$DOMAIN4" "$DOMAIN5" "$DOMAIN6")
raw_COMPONENTID_array=("$COMPONENTID1" "$COMPONENTID2" "$COMPONENTID3" "$COMPONENTID4" "$COMPONENTID5" "$COMPONENTID6")
DOMAIN_array=()
COMPONENTID_array=()


for i in {0..5}; do
    # Query status (DOMAIN)
    domain_status=$(wget --spider -S "${raw_DOMAIN_array[$i]}" 2>&1 | grep "HTTP/" | awk '{print $2}')
    domain_status=${domain_status: -3}
    DOMAIN_array[$i]="$domain_status"
done

#PREVIOUS QUERY
quest_incident_first=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/unresolved | cut -c9-20)

if [[ "${DOMAIN_array[*]}" == "200 200 200 200 200 200" ]] && [ -z "$quest_incident_first" ]; then
    echo "STATUS: OKAY"
    #If there are no errors

else    
    echo "STATUS: FAILURE"
    #When Errors Exist
    # query status (STATUSPAGE) - IncidentID checker
    quest_incident=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/unresolved | cut -c9-20)
    for schleife in {0..5}; do

        quest_incident_actual=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/unresolved | cut -c9-20)

        # query status (STATUSPAGE) - COMPONENTID
        quest_status=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/components/"${raw_COMPONENTID_array[$schleife]}")
        COMPONENTID_array[$i]="$quest_status"

        quest_COMPO_id=$(curl --silent -H "Authorization: OAuth "${AUTHKEY}"" -X GET https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/unresolved | cut -c216-227)

        if [ ! -z "$quest_incident_actual" ] && [ "${DOMAIN_array[$schleife]}" = "200" ] && [[ ! "$quest_status" == *"operational"* ]]; then
            #QUERY IF ERRORS ALREADY EXIST
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X PATCH -d "incident[status]=resolved" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=operational" -d "incident[body]=page now available - automatically generated message" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/"$quest_incident"
            status="0.1"
            echo "$status" # ONLY FOR DEBUG

        elif [ "${DOMAIN_array[$schleife]}" == "200" ]; then
            echo "status domain: 200 - OK" #ONLY FOR FIRST DEBUG
            status="0"
            echo "$status" # ONLY FOR DEBUG
        elif [ -z "${DOMAIN_array[$schleife]}" ] && [[ ! "$quest_status" == *"major_outage"* ]]; then
            echo "status domain: --- - FAILED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=critical" -d "incident[body]=page not available - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=major_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="1"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "503" ] && [[ ! "$quest_status" == *"under_maintenance"* ]]; then
            echo "status domain: 503 - MAINTENANCE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=maintenance" -d "incident[body]=maintenance mode active - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=under_maintenance" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="2"
            echo "$status" # ONLY FOR DEBUG
        #4xx Client-errors   
        elif [ "${DOMAIN_array[$schleife]}" == "400" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 400 - BAD REQUEST" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=400 BAD REQUEST error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.1"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "401" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 401 - UNAUTHORIZED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=401 - UNAUTHORIZED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.2"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "402" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 402 - PAYMENT REQUIRED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=402 PAYMENT REQUIRED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.3"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "403" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 403 - FORBIDDEN" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=403 FORBIDDEN error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.4"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "404" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 404 - NOT FOUND" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=404 Not Found error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.5"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "405" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 405 - METHOD NOT ALLOWED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=405 METHOD NOT ALLOWED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.6"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "406" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 406 - NOT ACCEPTABLE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=406 NOT ACCEPTABLE error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.7"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "407" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 407 - PROXY AUTHENTICATION REQUIRED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=407 PROXY AUTHENTICATION REQUIRED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.8"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "408" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 408 - REQUEST TIMEOUT" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=408 REQUEST TIMEOUT error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.9"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "409" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 409 - CONFLICT" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=409 CONFLICT error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.10"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "410" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 410 - GONE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=410 GONE error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.11"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "411" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 411 - LENGTH REQUIRED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=411 LENGTH REQUIRED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.12"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "412" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 412 - PRECONDITION FAILED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=412 PRECONDITION FAILED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.13"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "413" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 413 - PAYLOAD TO LARGE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=413 PAYLOAD TO LARGE error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.14"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "414" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 414 - URI TOO LONG" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=414 URI TOO LONG error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.15"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "415" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 415 - UNSUPPORTED MEDIA TYPE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=415 UNSUPPORTED MEDIA TYPE error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.16"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "416" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 416 - RANGE NOT SATISFIABLE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=416 RANGE NOT SATISFIABLE error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.17"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "417" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 417 - EXPECTATION FAILED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=417 EXPECTATION FAILED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.18"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "418" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 418 - I'M A TEAPOT" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=418 I'M A TEAPOT error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.19"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "421" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 421 - MISDIRECTED REQUEST" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=421 MISDIRECTED REQUEST error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.20"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "422" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 422 - UNPROCESSABLE ENTITY" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=422 UNPROCESSABLE ENTITY error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.21"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "423" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 423 - LOCKED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=423 LOCKED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.22"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "424" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 424 - FAILED DEPENDENCY" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=424 FAILED DEPENDENCY error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.23"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "425" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 425 - TOO EARLY" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=425 TOO EARLY error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.24"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "426" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 426 - UPGRADE REQUIRED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=426 UPGRADE REQUIRED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.25"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "428" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 428 - PRECONDITION REQUIRED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=428 PRECONDITION REQUIRED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.26"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "429" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 429 - TOO MANY REQUESTS" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=429 TOO MANY REQUESTS error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.27"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "431" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 431 - REQUEST HEADER FIELDS TOO LARGE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=431 REQUEST HEADER FIELDS TOO LARGE error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.28"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "451" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 451 - UNAVAILABLE FOR LEGAL REASONS" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=451 UNAVAILABLE FOR LEGAL REASONS error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="4.29"
            echo "$status" # ONLY FOR DEBUG
        
        #5xx Server-errors
        elif [ "${DOMAIN_array[$schleife]}" == "500" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 500 - INTERNAL SERVER ERROR" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=major" -d "incident[body]=500 INTERNAL SERVER ERROR (error) - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.1"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "501" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 501 - NOT IMPLEMENTED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=501 NOT IMPLEMENTED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.2"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "502" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 502 - BAD GATEWAY" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=502 BAD GATEWAY error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.3"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "503" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 503 - SERVICE UNAVAILIBLE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=maintenance" -d "incident[body]=503 SERVICE UNAVALIBLE error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.4"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "504" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 504 - GATEWAY TIMEOUT" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=504 GATEWAY TIMEOUT error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.5"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "505" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 505 - HTTP VERSION NOT SUPPORTED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=505 HTTP VERSION NOT SUPPORTED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.6"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "506" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 506 - VARIANT ALSO NEGOTITATES" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=506 VARIANT ALSO NEGOTITATES error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.7"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "507" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 507 - INSUFFICIENT STORAGE" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=507 INSUFFICIENT STORAGE error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.8"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "508" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 508 - LOOP DETECTED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=508 LOOP DETECTED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.9"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "510" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 510 - NOT EXTENDED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=510 NOT EXTENDED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.10"
            echo "$status" # ONLY FOR DEBUG
        elif [ "${DOMAIN_array[$schleife]}" == "511" ] && [[ ! "$quest_status" == *"partial_outage"* ]]; then
            echo "status domain: 511 - NETWORK AUTHENTICATION REQUIRED" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X POST -d "incident[name]=unknown fault" -d "incident[status]=investigating" -d "incident[impact_override]=minor" -d "incident[body]=511 NETWORK AUTHENTICATION REQUIRED error - automatically generated message" -d "incident[components["${raw_COMPONENTID_array[$schleife]}"]]=partial_outage" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents
            status="5.11"
            echo "$status" # ONLY FOR DEBUG

        else
            freeplace="err"
        fi
        ## query if incidents without website error are active
        if [[ "${DOMAIN_array[*]}" == "200 200 200 200 200 200" ]] && [ ! -z "$quest_incident_actual" ]; then
            echo "INTERNAL PROCESS ERROR - INCIDENT PRESENT WITHOUT ERROR OF A WEBSITE - automatically generated message" #ONLY FOR FIRST DEBUG
            curl -o /dev/null --silent -H "Authorization: OAuth "${AUTHKEY}"" -X PATCH -d "incident[status]=resolved" -d "incident[body]=Incident present without error of a website - automatically generated message" https://api.statuspage.io/v1/pages/"${PAGEID}"/incidents/"$quest_incident"
            status="0.5"
            echo "$status" # ONLY FOR DEBUG
        else
            freeplace="ok"
        fi
    done
fi
