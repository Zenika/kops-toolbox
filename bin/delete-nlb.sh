#!/bin/bash

#gets the list of all load balancers on the elbv2 API and deletes all those matching $CLUSTER_NAME environment variable value for tag key KubernetesCluster

ELB_ARN_LIST=$(aws elbv2 describe-load-balancers | awk '$1 ~ /^LOADBALANCERS/ {print $6}')


for i in $ELB_ARN_LIST
do
    CLUSTER_TAG=$(aws elbv2 describe-tags --resource-arn $i | awk '$2 ~ /^KubernetesCluster/ {print $3}')
    if [ "$CLUSTER_TAG" == "$CLUSTER_NAME" ] ;
    then
        echo -e "\nDeleting load balancer resource corresponding to ARN: $i\n"
        aws elbv2 delete-load-balancer --load-balancer-arn $i
    fi
done