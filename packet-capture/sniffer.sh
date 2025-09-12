#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <pod_name> [file_number]"
  exit 1
fi

pod_name_to_capture="$1"
file_number="${2:-2}"

_controllerIP_="x.x.x.x"
_controllerRESTAPIPort_="10443"
_neuvectorUsername_="admin"
_neuvectorPassword_='xxx'

cleanup() {
    rm -f token.json
}
trap cleanup EXIT

curl -sk -H "Content-Type: application/json" \
  -d '{"password": {"username": "'$_neuvectorUsername_'", "password": "'$_neuvectorPassword_'"}}' \
  "https://$_controllerIP_:$_controllerRESTAPIPort_/v1/auth" > token.json

_TOKEN_=$(jq -r '.token.token' token.json)

pod_id=$(curl -sk -H "X-Auth-Token: $_TOKEN_" \
  "https://$_controllerIP_:$_controllerRESTAPIPort_/v1/workload" \
  | jq -r --arg pod_name "$pod_name_to_capture" '.workloads[] | select(.pod_name==$pod_name and .labels["io.cri-containerd.kind"]=="sandbox") | .id')

if [ -z "$pod_id" ]; then
  echo "Pod $pod_name_to_capture not found or not a sandbox container"
  exit 1
fi

curl -sk -X POST \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: $_TOKEN_" \
  -d '{
    "sniffer": {
      "file_number": '"$file_number"',
      "duration": 0,
      "filter": ""
    }
  }' \
  "https://$_controllerIP_:$_controllerRESTAPIPort_/v1/sniffer?f_workload=$pod_id"
