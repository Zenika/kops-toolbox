#!/bin/bash

~/res/prod/cluster-template.sh > ~/res/prod/cluster-config.yaml

if [ "${CLUSTER_NAME}" = "" ] ; then echo "Aborting. Make sure you sourced the correct environment variables: CLUSTER_NAME" ; exit 1 ; fi

if [ "${KOPS_STATE_STORE}" = "" ] ; then echo "Aborting. Make sure you sourced the correct environment variables: CLUSTER_NAME" ; exit 1 ; fi

#while ! kops create secret --name ${CLUSTER_NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub 2> /dev/null ;
#    do
#        echo "Waiting for secret creation"
#        sleep 1
#done


kops create -f ~/res/prod/cluster-config.yaml

kops create secret --name ${CLUSTER_NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub

kops update cluster --name ${CLUSTER_NAME} --yes

while ! kops validate cluster 2> /dev/null ;
    do
        echo "Waiting for cluster validation"
        sleep 10
done

echo "the cluster is up and running"

while ! kubectl apply -f ~/res/addons/namespace-tooling.yaml 2> /dev/null ;
    do
        echo "Waiting for tooling namespace creation"
        sleep 1
done

while ! kubectl apply -f ~/res/addons/logging-elasticsearch.yaml 2> /dev/null ;
    do
        echo "Waiting for EFK stack deployment"
        sleep 1
done

while ! kubectl apply -f ~/res/addons/prometheus-operator.yaml 2> /dev/null ;
    do
        echo "Waiting for Prometheus operator deployment"
        sleep 1
done

while ! kubectl apply -f ~/res/addons/kubernetes-dashboard.yaml 2> /dev/null ;
    do
        echo "Waiting for cluster dashboard deployment"
        sleep 1
done

while ! kubectl apply -f ~/res/addons/kubernetes-cockpit.json 2> /dev/null ;
    do
        echo "Waiting for Cockpit dashboard deployment"
        sleep 1
done



echo -e "\n\n ////////////////////// \n \n all components deployed"
echo -e "\n\n ////////////////////// \n \n $(kubectl cluster-info)"
echo -e "\n\n ////////////////////// \n \n $(kops get secrets admin --type secret -oplaintext) is your admin user token"
echo -e "\n\n ////////////////////// \n \n $(kops get secrets kube --type secret -oplaintext) is your kube user token \n\n ////////////////////// \n \n"
