#!/bin/bash

export AWS_PROFILE=$KOPS_USER
export KOPS_STATE_STORE=s3://$KOPS_USER-state-store
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)

