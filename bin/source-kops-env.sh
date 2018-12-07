#!/bin/bash

export AWS_PROFILE=$KOPS_USER
export KOPS_STATE_STORE=s3://$KOPS_GROUP-state-store
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
export KOPS_STATE_STORE_AWS=$KOPS_STATE_STORE
export KOPS_STATE_STORE_GCP=gs://$KOPS_GROUP-state-store

export STEP1=step01_basic_cluster
export STEP2=step02_basic_cluster_weave
export STEP3=step03_separated_tooling_environment
export STEP4=step04_adding_an_ingress_controller
export STEP5=step05_switch_ingress_controller_to_traefik