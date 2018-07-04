#!/bin/bash

if [ -z "$KOPS_USER" ]; then
  echo "Environment variable KOPS_USER must be defined. Aborting"
  exit 1
fi

rm -rf ~/.ssh

access_id_key=$(cat ~/.aws/credentials | grep "\[$KOPS_USER\]" -A 2 | grep aws_access_key_id | cut -d'=' -f2 | tr -d ' ')
if [ -z "$access_id_key" ]; then
  echo "No access key found to delete"
else
  aws iam delete-access-key --access-key-id $access_id_key --user-name $KOPS_USER
  cat ~/.aws/credentials | head -n 3 > ~/.aws/credentials.tmp
  mv ~/.aws/credentials.tmp ~/.aws/credentials
fi

aws iam remove-user-from-group --user-name $KOPS_USER --group-name $KOPS_USER
aws iam delete-user --user-name $KOPS_USER

aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $KOPS_USER
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $KOPS_USER
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $KOPS_USER
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $KOPS_USER
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $KOPS_USER

aws iam delete-group --group-name $KOPS_USER
