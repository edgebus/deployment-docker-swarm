#!/bin/sh
#

APP="${1}"
shift

if [ -d /run/vars ]; then
    for FILE_NAME in $(cd /run/vars && find * -type f -maxdepth 0 -print); do
        NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
        echo "{\"name\":\"Docker Entry Point\",\"level\":\"INFO\",\"message\":\"Expanding /run/vars/${FILE_NAME}\",\"time\":\"${NOW}\"}"
        set -e
        FILE_VALUE=$(cat "/run/vars/${FILE_NAME}")
        set +e
        eval "export $FILE_NAME='$FILE_VALUE'"
    done
else
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    echo "{\"name\":\"Docker Entry Point\",\"level\":\"warn\",\"message\":\"WARNING: Directory /run/vars does not provided. Skipping expand environment variables.\",\"time\":\"${NOW}\"}" >&2
fi

if [ -d /run/secrets ]; then
    for FILE_NAME in $(cd /run/secrets && find * -type f -maxdepth 0 -print); do
        NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
        echo "{\"name\":\"Docker Entry Point\",\"level\":\"INFO\",\"message\":\"Expanding /run/secrets/${FILE_NAME}\",\"time\":\"${NOW}\"}"
        set -e
        FILE_VALUE=$(cat "/run/secrets/${FILE_NAME}")
        set +e
        eval "export $FILE_NAME='$FILE_VALUE'"
    done
else
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    echo "{\"name\":\"Docker Entry Point\",\"level\":\"warn\",\"message\":\"WARNING: Directory /run/secrets does not provided. Skipping expand environment variables.\",\"time\":\"${NOW}\"}" >&2
fi

exec "${APP}" "$@"
