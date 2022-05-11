#!/bin/bash

echo "List of new projects:"
echo

COUNTER=0
for repository in $(cat .repositories); do
  PROJECT_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1)
  FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | awk '{print tolower($0)}')
  FILE_CONF=docker/sites/$FILE_NAME.conf

  if [ ! -f "$FILE_CONF" ]; then
    echo "[$COUNTER] - "$PROJECT_NAME
  fi

  COUNTER=$((COUNTER + 1))
done

if [ $COUNTER = 0 ]; then
  echo "No unidentified projects!"
  echo "Add repository url to file .repositories for new projects!"
  exit
fi