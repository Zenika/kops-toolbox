#!/bin/bash

echo -e "\n\n ////////////////////// \n \n $(kubectl cluster-info)"
echo -e "\n\n ////////////////////// \n \n add '/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/' to dashboard URL"
echo -e "\n\n ////////////////////// \n \n $(kops get secrets admin --type secret -oplaintext) is your admin user token"
echo -e "\n\n ////////////////////// \n \n $(kops get secrets kube --type secret -oplaintext) is your kube user token \n\n ////////////////////// \n \n"
