#!/bin/bash

if [ -z "$KOPS_USER" ]; then
  echo "Environment variable KOPS_USER must be defined. Aborting"
  exit 1
fi

inject-aws-access-key-to-credentials() {
  while read \
    token_type \
    access_key_id \
    access_key_creation_date \
    secret_key_id \
    state \
    user_name; do 
    printf "$access_key_id\n$secret_key_id\n$AWS_REGION\ntext\n"
  done
}

access_id_key=$(cat ~/.aws/credentials | grep "\[$KOPS_USER\]" -A 2 | grep aws_access_key_id | cut -d'=' -f2 | tr -d ' ')
if [ -n "$access_id_key" ]; then
  echo "Access key already exists. Aborting"
  exit 1
fi


aws iam create-access-key --user-name $KOPS_USER | inject-aws-access-key-to-credentials | aws configure --profile $KOPS_USER
