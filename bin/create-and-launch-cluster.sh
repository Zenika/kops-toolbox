#!/bin/bash

~/res/cluster-template.sh > ~/res/cluster-config.yaml

if [ "${CLUSTER_NAME}" = "" ] ; then echo "Aborting. Make sure you sourced the correct environment variables: CLUSTER_NAME" ; exit 1 ; fi

if [ "${KOPS_STATE_STORE}" = "" ] ; then echo "Aborting. Make sure you sourced the correct environment variables: CLUSTER_NAME" ; exit 1 ; fi


kops create secret --name vincent.gilles.kops.k8s.local sshpublickey admin -i ~/.ssh/id_rsa.pub

kops create -f ~/res/cluster-config.yaml
kops update cluster --name ${CLUSTER_NAME} --yes

while ! kops validate cluster 2> res/null ;
    do
        echo "Waiting for cluster validation"
        sleep 1
done

echo "the cluster is up and running"

kubectl apply -f res/addons/namespace-logging.yaml
kubectl apply -f res/addons/logging-elasticsearch.yaml
kubectl apply -f res/addons/prometheus-operator.yaml
kubectl apply -f res/addons/kubernetes-dashboard.yaml
kubectl apply -f res/addons/kubernetes-cockpit.json


echo -e "\n ////////////////////// \n \n $(kops get secrets admin --type secret -oplaintext) is your admin user token"
echo -e "\n ////////////////////// \n \n $(kops get secrets kube --type secret -oplaintext) is your kube user token"


rm -f res/null