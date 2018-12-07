#!/bin/bash

~/step02_basic_cluster_weave/cluster-template-weave.sh > ~/generated_files/cluster-config-${STEP2}.yaml

if [ "${CLUSTER_NAME}" = "" ] ; then echo "Aborting. Make sure you sourced the correct environment variables: CLUSTER_NAME" ; exit 1 ; fi

if [ "${KOPS_STATE_STORE}" = "" ] ; then echo "Aborting. Make sure you sourced the correct environment variables: CLUSTER_NAME" ; exit 1 ; fi

#while ! kops create secret --name ${CLUSTER_NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub 2> /dev/null ;
#    do
#        echo "Waiting for secret creation"
#        sleep 1
#done


kops create -f ~/res/networking_tests/cluster-config.yaml

kops create secret --name ${CLUSTER_NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub

kops update cluster --name ${CLUSTER_NAME} --yes

while ! kops validate cluster 2> /dev/null ;
    do
        echo "Waiting for cluster validation"
        sleep 10
done

echo "the cluster is up and running"

while ! kubectl apply -f ~/res/addons/kubernetes-dashboard.yaml 2> /dev/null ;
    do
        echo "Waiting for cluster dashboard deployment"
        sleep 1
done

echo -e "\n\n ////////////////////// \n \n all components deployed"
echo -e "\n\n ////////////////////// \n \n $(kubectl cluster-info)"
echo -e "\n\n ////////////////////// \n \n You may access your dashboard on the following URL: $(kubectl cluster-info | awk '$1 ~ /Kubernetes/ {print $6}')"
echo -e "\nIf you are running Kubernetes 1.10 and higher, you may want to access your dashboard via the proxy: $(kubectl cluster-info  | awk '$1 ~ /Kubernetes/ {print $6}')/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
echo -e "\n\n ////////////////////// \n \n $(kops get secrets admin --type secret -oplaintext) is your admin user token"
echo -e "\n\n ////////////////////// \n \n $(kops get secrets kube --type secret -oplaintext) is your kube user token \n\n ////////////////////// \n \n"
