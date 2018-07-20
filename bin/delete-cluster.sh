#!/bin/bash

kops delete cluster $CLUSTER_NAME --yes


rm -f ~/res/cluster-config.yaml