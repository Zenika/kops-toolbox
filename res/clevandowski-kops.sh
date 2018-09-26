#!/bin/bash

#kops create cluster \
#    --zones ${AWS_REGION}a \
#    --name $CLUSTER_NAME \
#    --master-size=t2.large \
#    --node-size=t2.xlarge \
#    --master-count=1 \
#    --node-count=5

kops create cluster \
    --zones ${AWS_REGION}a \
    --name $CLUSTER_NAME \
    --master-size=t2.medium \
    --node-size=t2.xlarge \
    --master-count=1 \
    --node-count=5

kops update cluster ${CLUSTER_NAME} --yes

while ! kops validate cluster >/dev/null 2>&1; do echo "Waiting for cluster initialization..."; sleep 10; done


kubectl apply -n tooling -f ~/res/addons/namespace-tooling.yaml
kubectl apply -n tooling -f ~/res/addons/logging-elasticsearch.yaml
kubectl apply -n tooling -f ~/res/addons/prometheus-operator.yaml
kubectl apply -f ~/res/addons/kubernetes-dashboard.yaml
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

kubectl cluster-info
kops get secrets kube --type secret -oplaintext
kops get secrets admin --type secret -oplaintext
