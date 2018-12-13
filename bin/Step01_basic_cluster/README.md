# kops-toolbox

## Step 01 - Basic cluster

Just a basic Kubernetes cluster: 3 master nodes and 6 worker nodes split accross eu-west-3 region (Paris).

* Master nodes each have their own instance group (so one per availability zone). This is due to the way Kops works to avoid quorum issues among the master nodes.
* Kubernetes version: 1.10.11


### Launch the cluster

```
./create-and-launch-cluster.sh
```

### Delete the cluster

```
./delete-cluster.sh
```
