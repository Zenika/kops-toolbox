#!/bin/bash

echo -e "Deleting all NLB with tag key KubernetesCluster value matches $CLUSTER_NAME\n"
~/bin/delete-nlb.sh


echo -e "About to start deleting cluster $CLUSTER_NAME\n"
kops delete cluster $CLUSTER_NAME --yes

echo -e "Deleting the generated config file for cluster $CLUSTER_NAME\n"
rm -f ~/generated_files/cluster-config-${STEP2}.yaml

echo -e "Deletion complete\n\n"