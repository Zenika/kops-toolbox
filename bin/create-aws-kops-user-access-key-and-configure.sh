#!/bin/bash

inject-aws-access-key-to-credentials() {
  while read \
    token_type \
    access_key_id \
    access_key_creation_date \
    secret_key_id \
    state \
    user_name; do 
    # echo "$token_type $access_key_id $access_key_creation_date $secret_key_id $state $user_name"
    printf "$access_key_id\n$secret_key_id\neu-west-3\ntext\n"
#    echo "access_key_id: $access_key_id" 1>&2
  done
}

access_id_key=$(cat ~/.aws/credentials | grep "\[clevandowski-kops\]" -A 2 | grep aws_access_key_id | cut -d'=' -f2 | tr -d ' ')
if [ -n "$access_id_key" ]; then
  echo "Access key already exists. Aborting"
  exit 1
fi


aws iam create-access-key --user-name clevandowski-kops | inject-aws-access-key-to-credentials | aws configure --profile clevandowski-kops
