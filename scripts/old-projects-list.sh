#!/bin/bash

echo "List of installed projects:"
echo

COUNTER=0

for project in src/*/*; do
  PROJECT_NAME=$(echo $project | cut -d '/' -f3)
  FILE_NAME=$(echo $PROJECT_NAME | awk '{print tolower($0)}')
  FILE_CONF=docker/sites/$FILE_NAME.conf

  if [ -f "$FILE_CONF" ]; then
    echo "[$COUNTER] - "$PROJECT_NAME
    COUNTER=$((COUNTER + 1))
  fi
done

if [ $COUNTER = 0 ]; then
  echo "No identified projects!"
  echo "Install project before uninstalling!"
  exit
fi
