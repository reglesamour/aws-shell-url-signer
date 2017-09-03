#!/bin/bash
key_id="${1}"
key_secret="${2}"
host=${3}
path=${4}
date=$(date -u "+%Y-%m-%dT%H:%M:%SZ" | sed 's/:/%3A/g')
params="AWSAccessKeyId=${key_id}&Timestamp=${date}&$5"
paramsArr=(${params//&/ })
sortedParams=( $(
    for el in "${paramsArr[@]}"
    do
        echo "$el"
    done | sort) )
params=""
for index in ${!sortedParams[*]}
do
    params="$params&${sortedParams[$index]}"
done
params="${params:1}"
read -r -d '' string <<EOF
GET
$host
$path
$params
EOF
sig=$(echo -n "$string" | openssl dgst -sha256 -hmac $key_secret -binary | openssl enc -base64 | sed 's/+/%2B/g;s/=/%3D/g;') 
echo "https://${host}${path}?${params}&Signature=${sig}"