#!/bin/bash

cat << COINCOIN
apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  creationTimestamp: null
  name: $CLUSTER_NAME
spec:
  additionalPolicies:
    node: |
      [
        {
        "Effect": "Allow",
        "Action": ["ecr:InitiateLayerUpload", "ecr:UploadLayerPart","ecr:CompleteLayerUpload","ecr:PutImage"],
        "Resource": ["*"]
        }
      ]
  api:
    loadBalancer:
      type: Public
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: $KOPS_STATE_STORE/$CLUSTER_NAME
  etcdClusters:
  - etcdMembers:
    - instanceGroup: master-eu-west-3a
      name: a
    - instanceGroup: master-eu-west-3b
      name: b
    - instanceGroup: master-eu-west-3c
      name: c
    name: main
  - etcdMembers:
    - instanceGroup: master-eu-west-3a
      name: a
    - instanceGroup: master-eu-west-3b
      name: b
    - instanceGroup: master-eu-west-3c
      name: c
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  kubernetesApiAccess:
  - 0.0.0.0/0
  kubernetesVersion: 1.9.6
  masterPublicName: api.$CLUSTER_NAME
  networkCIDR: 172.20.0.0/16
  networking:
    weave:
      mtu: 8912
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  - 0.0.0.0/0
  subnets:
  - cidr: 172.20.32.0/19
    name: eu-west-3a
    type: Public
    zone: eu-west-3a
  - cidr: 172.20.64.0/19
    name: eu-west-3b
    type: Public
    zone: eu-west-3b
  - cidr: 172.20.96.0/19
    name: eu-west-3c
    type: Public
    zone: eu-west-3c
  topology:
    dns:
      type: Public
    masters: public
    nodes: public

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: null
  labels:
    kops.k8s.io/cluster: $CLUSTER_NAME
  name: master-eu-west-3a
spec:
  image: kope.io/k8s-1.9-debian-jessie-amd64-hvm-ebs-2018-03-11
  machineType: t2.medium
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: master-eu-west-3a
  cloudLabels:
    owner: $KOPS_USER
  role: Master
  subnets:
  - eu-west-3a

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: null
  labels:
    kops.k8s.io/cluster: $CLUSTER_NAME
  name: master-eu-west-3b
spec:
  image: kope.io/k8s-1.9-debian-jessie-amd64-hvm-ebs-2018-03-11
  machineType: t2.medium
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: master-eu-west-3b
  cloudLabels:
    owner: $KOPS_USER
  role: Master
  subnets:
  - eu-west-3b

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: null
  labels:
    kops.k8s.io/cluster: $CLUSTER_NAME
  name: master-eu-west-3c
spec:
  image: kope.io/k8s-1.9-debian-jessie-amd64-hvm-ebs-2018-03-11
  machineType: t2.medium
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: master-eu-west-3c
  cloudLabels:
    owner: $KOPS_USER
  role: Master
  subnets:
  - eu-west-3c

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: null
  labels:
    kops.k8s.io/cluster: $CLUSTER_NAME
  name: prod
spec:
  image: kope.io/k8s-1.9-debian-jessie-amd64-hvm-ebs-2018-03-11
  machineType: t2.large
  maxSize: 6
  minSize: 6
  cloudLabels:
    owner: $KOPS_USER
  role: Node
  subnets:
  - eu-west-3a
  - eu-west-3b
  - eu-west-3c

COINCOIN
