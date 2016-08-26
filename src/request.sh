#!/bin/bash
#
# Make HTTP requests with an auth token. Requires Bash 3 or greater.
#

# Ensure that Bash is compatible
BASH_MAJOR_VERSION=$(echo "$BASH_VERSION" | awk 'BEGIN { FS = "." }; { print $1 }')
if [[ $BASH_MAJOR_VERSION -lt 3 ]]
then
    >&2 echo "You are using a very old version of bash ($BASH_VERSION). This script needs at least version 3 to run."
    exit 1
fi

USERNAME='administrator@daptiv.com'
PASSWORD='password'
BODY=''
METHOD='GET'
AUTHPORT=9099
REQPORT=80

function print_usage() {
  cat << UsageMessage
Usage: $0 [options...] <url>
Options:
 -b BODY        Body to be sent with the request
 -f BODYFILE    If included, a file will be read and passed as the request body
 -m METHOD      The HTTP method to use
 -o PORT        Port to use for the auth server. Defaults to 9099
 -p PASSWORD    Password to provide to the auth server. Defaults to 'password'
 -u USERNAME    Username to provide to the auth server. Defaults to 'administrator@daptiv.com'
UsageMessage
}

while getopts "f:u:p:m:o:b:" OPT
do
  case $OPT in
    b)
      BODY=$OPTARG
      ;;
    f)
      BODY=$(cat $OPTARG)
      ;;
    u)
      USERNAME=$OPTARG
      ;;
    p)
      PASSWORD=$OPTARG
      ;;
    m)
      METHOD=$OPTARG
      ;;
    o)
      AUTHPORT=$OPTARG
      ;;
    \?)
      print_usage
      exit 1
      ;;
  esac
done

shift $(expr $OPTIND - 1)
URL=$1

if [[ -z $URL ]]
then
  print_usage
  exit 1
fi

AUTH_RESPONSE=$(curl \
  -sS \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Authorization: Basic cHBtOm9ubHkxc2VjcmV0NFFB' \
  -d "grant_type=password&scope=ppm+offline_access&username=${USERNAME}&password=${PASSWORD}" \
  "http://devauth.daptiv.com:${AUTHPORT}/connect/token")

echo "$AUTH_RESPONSE"

TOKEN_REGEX='"access_token":"([^"]*)'
[[ $AUTH_RESPONSE =~ $TOKEN_REGEX ]]
AUTH_TOKEN="${BASH_REMATCH[1]}"

API_RESPONSE=$(curl \
  -sSi \
  -X $METHOD \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d "$BODY" \
  "${URL}")

# Print headers
echo "$API_RESPONSE"
