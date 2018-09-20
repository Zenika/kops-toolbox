#!/bin/bash

ELB_DESCRIPTION=$(aws elbv2 describe-load-balancers)
echo $VAR | grep com

ELB_ARN=$(echo $ELB_DESCRIPTION | awk '{print $6}')
ELB_DNS=$(echo $ELB_DESCRIPTION | awk '{print $4}')

echo -e "\nThis is the NLB's ARN: $ELB_ARN\nThis is the NLB's DNS address: $ELB_DNS"

echo -e "\nTo delete the NLB, type the following command: aws elbv2 delete-load-balancer --load-balancer-arn $ELB_ARN\n"
