#!/bin/bash

# export KOPS_STATE_STORE=s3://clevandowski-kops-state-store
kops export kubecfg --state $KOPS_STATE_STORE --name=$CLUSTER_NAME
