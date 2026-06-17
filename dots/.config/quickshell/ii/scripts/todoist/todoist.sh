#!/usr/bin/env bash
# Script to interface with Todoist API

if [ -f ~/.config/quickshell/ii/.env ]; then
    source ~/.config/quickshell/ii/.env
fi

if [ -z "$TODOIST_API_KEY" ]; then
    echo '{"error": "TODOIST_API_KEY not set"}'
    exit 1
fi

ACTION=$1
ARG=$2

if [ "$ACTION" == "fetch" ]; then
    ACTIVE=$(curl -s -X GET https://api.todoist.com/api/v1/tasks \
        -H "Authorization: Bearer $TODOIST_API_KEY")

    COMPLETED=$(curl -s -X GET "https://api.todoist.com/api/v1/tasks/completed?limit=30" \
        -H "Authorization: Bearer $TODOIST_API_KEY")

    echo "{\"active\": $ACTIVE, \"completed\": $COMPLETED}"
elif [ "$ACTION" == "add" ]; then
    curl -s -X POST https://api.todoist.com/api/v1/tasks \
        -H "Authorization: Bearer $TODOIST_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"$ARG\"}"
elif [ "$ACTION" == "close" ]; then
    curl -s -X POST https://api.todoist.com/api/v1/tasks/$ARG/close \
        -H "Authorization: Bearer $TODOIST_API_KEY"
elif [ "$ACTION" == "unclose" ]; then
    curl -s -X POST https://api.todoist.com/api/v1/tasks/$ARG/reopen \
        -H "Authorization: Bearer $TODOIST_API_KEY"
elif [ "$ACTION" == "delete" ]; then
    curl -s -X DELETE https://api.todoist.com/api/v1/tasks/$ARG \
        -H "Authorization: Bearer $TODOIST_API_KEY"
else
    echo '{"error": "Unknown action"}'
    exit 1
fi
