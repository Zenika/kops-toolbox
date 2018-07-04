#!/bin/bash

if [ -z "$KOPS_USER" ]; then
  echo "Environment variable KOPS_USER must be defined. Aborting"
  exit 1
fi

access_id_key=$(cat ~/.aws/credentials | grep "\[$KOPS_USER\]" -A 2 | grep aws_access_key_id | cut -d'=' -f2 | tr -d ' ')
if [ -z "$access_id_key" ]; then
  echo "No access key found to delete. Aborting"
  exit 1
fi

aws iam delete-access-key --access-key-id $access_id_key --user-name $KOPS_USER

cat ~/.aws/credentials | head -n 3 > ~/.aws/credentials.tmp
mv ~/.aws/credentials.tmp ~/.aws/credentials
