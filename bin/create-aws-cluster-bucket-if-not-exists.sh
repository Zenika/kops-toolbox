#!/bin/bash

if [ -z "$KOPS_USER" ]; then
  echo "Environment variable KOPS_USER must be defined. Aborting"
  exit 1
fi

if [ -z "$KOPS_GROUP" ]; then
  echo "Environment variable KOPS_GROUP must be defined. Aborting"
  exit 1
fi

while ! aws s3api --profile $KOPS_USER list-buckets --output text >.buckets 2>/dev/null; do
  echo "Waiting for AWS access key user registration"
  sleep 1
done

if cat .buckets | grep $KOPS_GROUP-state-store >/dev/null; then
  echo "AWS S3 bucket $KOPS_GROUP-state-store already exists"
else
  echo "Creating AWS S3 bucket $KOPS_GROUP-state-store"

  while ! aws --profile $KOPS_USER s3api create-bucket \
    --bucket $KOPS_GROUP-state-store \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION; do
    echo "Waiting for AWS access key user registration"
    sleep 1
  done
fi

rm .buckets
