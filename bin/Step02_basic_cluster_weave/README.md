# kops-toolbox

## Step 02 - Basic cluster with weave

Same cluster as in step 01 but the default network plugin (Kubenet) has been replaced by Weave. 

** Master nodes each have their own instance group (so one per availability zone). This is due to the way Kops works to avoid quorum issues among the master nodes.
** Kubernetes version: 1.10.11
** Network plugin: Weave


### Launch the cluster

```
./create-and-launch-cluster.sh
```

### Delete the cluster

```
./delete-cluster.sh
```