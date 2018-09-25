#!/bin/bash

# gets the hosted zone matching $CLUSTER_DOMAIN domain's ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones | awk -v pattern=$CLUSTER_DOMAIN '$4 ~ pattern {print $3}' | awk 'BEGIN { FS="/" } {print $3}')

# gets the NLB's DNS address // DUPLICATE CODE WITH delete-cluster.sh
ELB_ARN_LIST=$(aws elbv2 describe-load-balancers | awk '$1 ~ /^LOADBALANCERS/ {print $6}')


#for each ELB ARN, check if it belongs to the cluster. If so, get its DNS name.
for i in $ELB_ARN_LIST
do
    CLUSTER_TAG=$(aws elbv2 describe-tags --resource-arn $i | awk '$2 ~ /^KubernetesCluster/ {print $3}')
    if [ "$CLUSTER_TAG" == "$CLUSTER_NAME" ] ;
    then
        DNS_NAME="$(aws elbv2 describe-load-balancers --load-balancer-arns $i | awk '$1 ~/^LOADBALANCERS/ {print$4}')"
        echo -e "export DNS_NAME=$DNS_NAME\nexport HOSTED_ZONE_ID=$HOSTED_ZONE_ID" > ~/variables.sh
        source ~/variables.sh
    fi
done

#create a cname record resource file
~/res/addons/cname-record-template.sh > ~/res/addons/cname-record.json

#upsert that cname record
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://~/res/addons/cname-record.json


rm -f ~/variables.sh