#!/bin/bash

inject-aws-access-key-to-credentials() {
  while read \
    token_type \
    access_key_id \
    access_key_creation_date \
    secret_key_id \
    state \
    user_name; do 
    printf "$access_key_id\n$secret_key_id\n$AWS_REGION\ntext\n\n"
  done
}

if [ -z "$KOPS_USER" ]; then
  echo "Environment variable KOPS_USER must be defined. Aborting"
  exit 1
fi

export AWS_PROFILE=default
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

if aws iam list-groups --output text | grep $KOPS_USER >/dev/null; then
  echo "AWS group $KOPS_USER already exists"
else
  echo "Creating AWS group $KOPS_USER"
  aws iam create-group --group-name $KOPS_USER --output text
fi

ATTACHED_GROUP_POLICIES=$(aws iam list-attached-group-policies --group-name $KOPS_USER --output text)

for NEEDED_ATTACHED_GROUP_POLICIES in AmazonEC2FullAccess AmazonRoute53FullAccess AmazonS3FullAccess IAMFullAccess AmazonVPCFullAccess; do
  if echo $ATTACHED_GROUP_POLICIES | grep $NEEDED_ATTACHED_GROUP_POLICIES >/dev/null; then
    echo "Group-policy $NEEDED_ATTACHED_GROUP_POLICIES already attached to group $KOPS_USER"
  else
    echo "Missing group-policy $NEEDED_ATTACHED_GROUP_POLICIES. Attaching"
    aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/$NEEDED_ATTACHED_GROUP_POLICIES --group-name $KOPS_USER --output text
  fi
done

if aws iam list-users --output text | grep $KOPS_USER >/dev/null; then
  echo "AWS user $KOPS_USER already exists"
else
  echo "Creating AWS user $KOPS_USER"
  aws iam create-user --user-name $KOPS_USER --output text
  aws iam add-user-to-group --user-name $KOPS_USER --group-name $KOPS_USER --output text
fi

access_id_key=$(cat ~/.aws/credentials | grep "\[$KOPS_USER\]" -A 2 | grep aws_access_key_id | cut -d'=' -f2 | tr -d ' ')
if [ -n "$access_id_key" ]; then
  echo "AWS access key already exists for user $KOPS_USER"
else
  echo "Injecting AWS access key for user $KOPS_USER"
  aws iam --output text create-access-key --user-name $KOPS_USER | inject-aws-access-key-to-credentials | aws configure --profile $KOPS_USER
fi

. ~/bin/source-kops-env.sh

while ! aws s3api --profile $KOPS_USER list-buckets --output text >.buckets 2>/dev/null; do
  echo "Waiting for AWS access key user registration"
  sleep 1
done

if cat .buckets | grep $KOPS_USER-state-store >/dev/null; then
  echo "AWS S3 bucket $KOPS_USER-state-store already exists"
else
  echo "Creating AWS S3 bucket $KOPS_USER-state-store"

  while ! aws --profile $KOPS_USER s3api create-bucket \
    --bucket $KOPS_USER-state-store \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION; do
    echo "Waiting for AWS access key user registration"
    sleep 1
  done
fi

rm .buckets
