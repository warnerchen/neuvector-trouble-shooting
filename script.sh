#!/bin/bash

_controllerIP_="x.x.x.x"
_controllerRESTAPIPort_="10443"
_neuvectorUsername_="admin"
_neuvectorPassword_="x.x.x.x"

usage () {
    echo "Usage: `basename $0` (on|off) [controller|enforcer]"
    exit 1
}

if [ -z "$1" ] || [ -z "$2" ]; then
    usage
fi

if [ "$1" == "on" ]; then
    DISABLE_NVPROTECT="false"
elif [ "$1" == "off" ]; then
    DISABLE_NVPROTECT="true"
else
    usage
fi

if [ "$2" != "controller" ] && [ "$2" != "enforcer" ]; then
    echo "Error: Second argument must be one of 'controller' or 'enforcer'."
    exit 1
fi

# Get Token
TOKEN_JSON=$(curl -sk -H "Content-Type: application/json" \
    -d "{\"password\": {\"username\": \"$_neuvectorUsername_\", \"password\": \"$_neuvectorPassword_\"}}" \
    "https://$_controllerIP_:$_controllerRESTAPIPort_/v1/auth")

_TOKEN_=$(echo "$TOKEN_JSON" | jq -r '.token.token')

if [ -z "$_TOKEN_" ] || [ "$_TOKEN_" == "null" ]; then
    echo "Failed to retrieve authentication token."
    exit 1
fi

# Get List Based on Type (Controller, Enforcer)
curlHeaders=('-H' "Content-Type: application/json" '-H' "X-Auth-Token: $_TOKEN_")
echo "Fetching $2s..."
if [ "$2" == "controller" ]; then
    COMPONENTS=$(curl -ks --location --request GET "https://${_controllerIP_}:${_controllerRESTAPIPort_}/v1/controller" "${curlHeaders[@]}" | jq -r '.controllers[] | .display_name + "::" + .id')
else
    COMPONENTS=$(curl -ks --location --request GET "https://${_controllerIP_}:${_controllerRESTAPIPort_}/v1/enforcer" "${curlHeaders[@]}" | jq -r '.enforcers[] | .display_name + "::" + .id')
fi

if [ -z "$COMPONENTS" ]; then
    echo "No $2s found."
    exit 1
fi

# Change nvprotect setting for each component
for comp in $COMPONENTS; do
    COMPONENT_NAME="${comp%%::*}"
    COMPONENT_ID="${comp##*::}"
    
    echo "Setting nvprotect to $1 on $COMPONENT_NAME..."
    curl -ks --location --request PATCH "https://${_controllerIP_}:${_controllerRESTAPIPort_}/v1/$2/${COMPONENT_ID}" \
        "${curlHeaders[@]}" --data "{\"config\": {\"disable_nvprotect\": $DISABLE_NVPROTECT}}"
done

# Logout
curl -ks -X 'DELETE' -H "Content-Type: application/json" -H "X-Auth-Token: $_TOKEN_" "https://$_controllerIP_:$_controllerRESTAPIPort_/v1/auth" > /dev/null 2>&1
echo "Logged Out"