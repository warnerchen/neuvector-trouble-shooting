#!/bin/bash

# set -x

_controllerIP_="x.x.x.x"
_controllerRESTAPIPort_="10443"
_neuvectorUsername_="admin"
_neuvectorPassword_="admin"
_neuvectorNamespace_="neuvector"

usage () {
        echo "Usage: `basename $0` (on|off)"
        exit 1
}

if [ -z $1 ]; then
    usage
fi

if [ "$1" == "on" ]; then
    STATE="/tmp/core-%e.%p.%h.%t"
elif [ "$1" == "off" ]; then
    STATE="|/bin/false"
else
    usage
fi

curl -k -H "Content-Type: application/json" -d '{"password": {"username": "'$_neuvectorUsername_'", "password": "'$_neuvectorPassword_'"}}' "https://$_controllerIP_:$_controllerRESTAPIPort_/v1/auth" > /dev/null 2>&1 > token.json
_TOKEN_=`cat token.json | jq -r '.token.token'`

declare -a curlHeaders=('-H' "Content-Type: application/json" '-H' "X-Auth-Token: $_TOKEN_")
echo "Pulling Enforcers"
declare -a enforcers="($(
    curl -ks --location --request GET https://${_controllerIP_}:${_controllerRESTAPIPort_}/v1/enforcer "${curlHeaders[@]}" | jq '.enforcers[] | .display_name + "::" +.id' -r ))"

if [ ${#enforcers[@]} -eq 0 ]; then
    echo
    echo "No enforcers found."
    exit 1
else
    for enf in "${enforcers[@]}" ; do
        ENFORCER_NAME="${enf%%::*}"
        ENFORCER_ID="${enf##*::}"
        echo "Temporarily disabling nvprotect on $ENFORCER_NAME"
        curl -ks --location --request PATCH https://${_controllerIP_}:${_controllerRESTAPIPort_}/v1/enforcer/${ENFORCER_ID} "${curlHeaders[@]}" --data '{"config": {"disable_nvprotect": true}}'
        echo "Configuring core_pattern with sysctl..."
        kubectl -n ${_neuvectorNamespace_} exec -it $ENFORCER_NAME -- sysctl -w kernel.core_pattern=$STATE
        echo "Restoring nvprotect"
        curl -ks --location --request PATCH https://${_controllerIP_}:${_controllerRESTAPIPort_}/v1/enforcer/${ENFORCER_ID} "${curlHeaders[@]}" --data '{"config": {"disable_nvprotect": false}}'
        echo "=========="
    done
fi

curl -k -X 'DELETE' -H "Content-Type: application/json" -H "X-Auth-Token: $_TOKEN_" "https://$_controllerIP_:$_controllerRESTAPIPort_/v1/auth" > /dev/null 2>&1
rm token.json
echo "Logged Out"