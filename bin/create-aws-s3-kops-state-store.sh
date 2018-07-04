#!/bin/bash

aws --profile $KOPS_USER s3api create-bucket \
    --bucket $KOPS_USER-state-store \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION
