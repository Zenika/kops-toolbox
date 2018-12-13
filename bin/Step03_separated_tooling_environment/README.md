# kops-toolbox

## Step 02 - Basic cluster with weave

Same cluster as in step 02 but this time we added different environments for prod and tooling. 

* Master nodes each have their own instance group (so one per availability zone). This is due to the way Kops works to avoid quorum issues among the master nodes.
* Kubernetes version: 1.10.11
* Network plugin: Weave
* Two separate worker nodes instance groups: prod and tooling.
* Tooling namespace created on the tooling instances.
* Deployments include: 
    * Kubernetes dashboard (Kube-system)
    * EFK stack (tooling)
    * Prometheus operator (tooling)


### Launch the cluster

```
./create-and-launch-cluster.sh
```

### Delete the cluster

```
./delete-cluster.sh
```

## More info

* The tooling deployments are bound to the tooling instances because they are the only ones on which the tooling namespace exists.
* Deployments with no further configuration will be scheduled on both prod and tooling nodes unless: 
    * They are bound to the prod instances the same way as the tooling is bound to the tooling instances. In this case, you need to create a prod namespace that only exists on the prod instances.
    * You make use of taints to only allow tooling deployments on the tooling instances. You should be able to do that using the kops.k8s.io/instancegroup node label.