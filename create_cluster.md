```
$ kops create cluster \
>     --zones ${AWS_REGION}a \
>     --name $NAME \
>     --master-size=t2.large \
>     --node-size=t2.large
I0704 14:00:46.704888     178 create_cluster.go:1318] Using SSH public key: /home/guest/.ssh/id_rsa.pub
I0704 14:00:47.380135     178 create_cluster.go:472] Inferred --cloud=aws from zone "eu-west-3a"
I0704 14:00:47.516948     178 subnets.go:184] Assigned CIDR 172.20.32.0/19 to subnet eu-west-3a
Previewing changes that will be made:

I0704 14:00:49.816723     178 apply_cluster.go:456] Gossip DNS: skipping DNS validation
I0704 14:00:49.833616     178 executor.go:91] Tasks: 0 done / 77 total; 30 can run
I0704 14:00:50.213271     178 executor.go:91] Tasks: 30 done / 77 total; 24 can run
I0704 14:00:50.439201     178 executor.go:91] Tasks: 54 done / 77 total; 19 can run
I0704 14:00:50.534070     178 executor.go:91] Tasks: 73 done / 77 total; 3 can run
W0704 14:00:50.545415     178 keypair.go:140] Task did not have an address: *awstasks.LoadBalancer {"Name":"api.clevandowski-kops.k8s.local","Lifecycle":"Sync","LoadBalancerName":"api-clevandowski-kops-k8s-2s9plg","DNSName":null,"HostedZoneId":null,"Subnets":[{"Name":"eu-west-3a.clevandowski-kops.k8s.local","Lifecycle":"Sync","ID":null,"VPC":{"Name":"clevandowski-kops.k8s.local","Lifecycle":"Sync","ID":null,"CIDR":"172.20.0.0/16","AdditionalCIDR":null,"EnableDNSHostnames":true,"EnableDNSSupport":true,"Shared":false,"Tags":{"KubernetesCluster":"clevandowski-kops.k8s.local","Name":"clevandowski-kops.k8s.local","kubernetes.io/cluster/clevandowski-kops.k8s.local":"owned"}},"AvailabilityZone":"eu-west-3a","CIDR":"172.20.32.0/19","Shared":false,"Tags":{"KubernetesCluster":"clevandowski-kops.k8s.local","Name":"eu-west-3a.clevandowski-kops.k8s.local","SubnetType":"Public","kubernetes.io/cluster/clevandowski-kops.k8s.local":"owned","kubernetes.io/role/elb":"1"}}],"SecurityGroups":[{"Name":"api-elb.clevandowski-kops.k8s.local","Lifecycle":"Sync","ID":null,"Description":"Security group for api ELB","VPC":{"Name":"clevandowski-kops.k8s.local","Lifecycle":"Sync","ID":null,"CIDR":"172.20.0.0/16","AdditionalCIDR":null,"EnableDNSHostnames":true,"EnableDNSSupport":true,"Shared":false,"Tags":{"KubernetesCluster":"clevandowski-kops.k8s.local","Name":"clevandowski-kops.k8s.local","kubernetes.io/cluster/clevandowski-kops.k8s.local":"owned"}},"RemoveExtraRules":["port=443"],"Shared":null,"Tags":{"KubernetesCluster":"clevandowski-kops.k8s.local","Name":"api-elb.clevandowski-kops.k8s.local","kubernetes.io/cluster/clevandowski-kops.k8s.local":"owned"}}],"Listeners":{"443":{"InstancePort":443}},"Scheme":null,"HealthCheck":{"Target":"SSL:443","HealthyThreshold":2,"UnhealthyThreshold":2,"Interval":10,"Timeout":5},"AccessLog":null,"ConnectionDraining":null,"ConnectionSettings":{"IdleTimeout":300},"CrossZoneLoadBalancing":null}
I0704 14:00:50.597668     178 executor.go:91] Tasks: 76 done / 77 total; 1 can run
I0704 14:00:50.635702     178 executor.go:91] Tasks: 77 done / 77 total; 0 can run
Will create resources:
  AutoscalingGroup/master-eu-west-3a.masters.clevandowski-kops.k8s.local
    MinSize               1
    MaxSize               1
    Subnets               [name:eu-west-3a.clevandowski-kops.k8s.local]
    Tags                  {k8s.io/role/master: 1, Name: master-eu-west-3a.masters.clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local, k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup: master-eu-west-3a}
    Granularity           1Minute
    Metrics               [GroupDesiredCapacity, GroupInServiceInstances, GroupMaxSize, GroupMinSize, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances]
    LaunchConfiguration   name:master-eu-west-3a.masters.clevandowski-kops.k8s.local

  AutoscalingGroup/nodes.clevandowski-kops.k8s.local
    MinSize               2
    MaxSize               2
    Subnets               [name:eu-west-3a.clevandowski-kops.k8s.local]
    Tags                  {Name: nodes.clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local, k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup: nodes, k8s.io/role/node: 1}
    Granularity           1Minute
    Metrics               [GroupDesiredCapacity, GroupInServiceInstances, GroupMaxSize, GroupMinSize, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances]
    LaunchConfiguration   name:nodes.clevandowski-kops.k8s.local

  DHCPOptions/clevandowski-kops.k8s.local
    DomainName            eu-west-3.compute.internal
    DomainNameServers     AmazonProvidedDNS
    Shared                false
    Tags                  {Name: clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned}

  EBSVolume/a.etcd-events.clevandowski-kops.k8s.local
    AvailabilityZone      eu-west-3a
    VolumeType            gp2
    SizeGB                20
    Encrypted             false
    Tags                  {k8s.io/etcd/events: a/a, k8s.io/role/master: 1, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned, Name: a.etcd-events.clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local}

  EBSVolume/a.etcd-main.clevandowski-kops.k8s.local
    AvailabilityZone      eu-west-3a
    VolumeType            gp2
    SizeGB                20
    Encrypted             false
    Tags                  {k8s.io/etcd/main: a/a, k8s.io/role/master: 1, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned, Name: a.etcd-main.clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local}

  IAMInstanceProfile/masters.clevandowski-kops.k8s.local

  IAMInstanceProfile/nodes.clevandowski-kops.k8s.local

  IAMInstanceProfileRole/masters.clevandowski-kops.k8s.local
    InstanceProfile       name:masters.clevandowski-kops.k8s.local id:masters.clevandowski-kops.k8s.local
    Role                  name:masters.clevandowski-kops.k8s.local

  IAMInstanceProfileRole/nodes.clevandowski-kops.k8s.local
    InstanceProfile       name:nodes.clevandowski-kops.k8s.local id:nodes.clevandowski-kops.k8s.local
    Role                  name:nodes.clevandowski-kops.k8s.local

  IAMRole/masters.clevandowski-kops.k8s.local
    ExportWithID          masters

  IAMRole/nodes.clevandowski-kops.k8s.local
    ExportWithID          nodes

  IAMRolePolicy/masters.clevandowski-kops.k8s.local
    Role                  name:masters.clevandowski-kops.k8s.local

  IAMRolePolicy/nodes.clevandowski-kops.k8s.local
    Role                  name:nodes.clevandowski-kops.k8s.local

  InternetGateway/clevandowski-kops.k8s.local
    VPC                   name:clevandowski-kops.k8s.local
    Shared                false
    Tags                  {KubernetesCluster: clevandowski-kops.k8s.local, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned, Name: clevandowski-kops.k8s.local}

  Keypair/apiserver-aggregator
    Signer                name:apiserver-aggregator-ca id:cn=apiserver-aggregator-ca
    Subject               cn=aggregator
    Type                  client
    Format                v1alpha2

  Keypair/apiserver-aggregator-ca
    Subject               cn=apiserver-aggregator-ca
    Type                  ca
    Format                v1alpha2

  Keypair/apiserver-proxy-client
    Signer                name:ca id:cn=kubernetes
    Subject               cn=apiserver-proxy-client
    Type                  client
    Format                v1alpha2

  Keypair/ca
    Subject               cn=kubernetes
    Type                  ca
    Format                v1alpha2

  Keypair/kops
    Signer                name:ca id:cn=kubernetes
    Subject               o=system:masters,cn=kops
    Type                  client
    Format                v1alpha2

  Keypair/kube-controller-manager
    Signer                name:ca id:cn=kubernetes
    Subject               cn=system:kube-controller-manager
    Type                  client
    Format                v1alpha2

  Keypair/kube-proxy
    Signer                name:ca id:cn=kubernetes
    Subject               cn=system:kube-proxy
    Type                  client
    Format                v1alpha2

  Keypair/kube-scheduler
    Signer                name:ca id:cn=kubernetes
    Subject               cn=system:kube-scheduler
    Type                  client
    Format                v1alpha2

  Keypair/kubecfg
    Signer                name:ca id:cn=kubernetes
    Subject               o=system:masters,cn=kubecfg
    Type                  client
    Format                v1alpha2

  Keypair/kubelet
    Signer                name:ca id:cn=kubernetes
    Subject               o=system:nodes,cn=kubelet
    Type                  client
    Format                v1alpha2

  Keypair/kubelet-api
    Signer                name:ca id:cn=kubernetes
    Subject               cn=kubelet-api
    Type                  client
    Format                v1alpha2

  Keypair/master
    AlternateNames        [100.64.0.1, 127.0.0.1, api.clevandowski-kops.k8s.local, api.internal.clevandowski-kops.k8s.local, kubernetes, kubernetes.default, kubernetes.default.svc, kubernetes.default.svc.cluster.local]
    Signer                name:ca id:cn=kubernetes
    Subject               cn=kubernetes-master
    Type                  server
    Format                v1alpha2

  LaunchConfiguration/master-eu-west-3a.masters.clevandowski-kops.k8s.local
    ImageID               kope.io/k8s-1.9-debian-jessie-amd64-hvm-ebs-2018-03-11
    InstanceType          t2.large
    SSHKey                name:kubernetes.clevandowski-kops.k8s.local-19:7f:d4:48:b9:69:39:0c:c6:e1:eb:90:70:b4:02:13 id:kubernetes.clevandowski-kops.k8s.local-19:7f:d4:48:b9:69:39:0c:c6:e1:eb:90:70:b4:02:13
    SecurityGroups        [name:masters.clevandowski-kops.k8s.local]
    AssociatePublicIP     true
    IAMInstanceProfile    name:masters.clevandowski-kops.k8s.local id:masters.clevandowski-kops.k8s.local
    RootVolumeSize        64
    RootVolumeType        gp2
    SpotPrice             

  LaunchConfiguration/nodes.clevandowski-kops.k8s.local
    ImageID               kope.io/k8s-1.9-debian-jessie-amd64-hvm-ebs-2018-03-11
    InstanceType          t2.large
    SSHKey                name:kubernetes.clevandowski-kops.k8s.local-19:7f:d4:48:b9:69:39:0c:c6:e1:eb:90:70:b4:02:13 id:kubernetes.clevandowski-kops.k8s.local-19:7f:d4:48:b9:69:39:0c:c6:e1:eb:90:70:b4:02:13
    SecurityGroups        [name:nodes.clevandowski-kops.k8s.local]
    AssociatePublicIP     true
    IAMInstanceProfile    name:nodes.clevandowski-kops.k8s.local id:nodes.clevandowski-kops.k8s.local
    RootVolumeSize        128
    RootVolumeType        gp2
    SpotPrice             

  LoadBalancer/api.clevandowski-kops.k8s.local
    LoadBalancerName      api-clevandowski-kops-k8s-2s9plg
    Subnets               [name:eu-west-3a.clevandowski-kops.k8s.local]
    SecurityGroups        [name:api-elb.clevandowski-kops.k8s.local]
    Listeners             {443: {"InstancePort":443}}
    HealthCheck           {"Target":"SSL:443","HealthyThreshold":2,"UnhealthyThreshold":2,"Interval":10,"Timeout":5}
    ConnectionSettings    {"IdleTimeout":300}

  LoadBalancerAttachment/api-master-eu-west-3a
    LoadBalancer          name:api.clevandowski-kops.k8s.local id:api.clevandowski-kops.k8s.local
    AutoscalingGroup      name:master-eu-west-3a.masters.clevandowski-kops.k8s.local id:master-eu-west-3a.masters.clevandowski-kops.k8s.local

  ManagedFile/clevandowski-kops.k8s.local-addons-bootstrap
    Location              addons/bootstrap-channel.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-core.addons.k8s.io
    Location              addons/core.addons.k8s.io/v1.4.0.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-dns-controller.addons.k8s.io-k8s-1.6
    Location              addons/dns-controller.addons.k8s.io/k8s-1.6.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-dns-controller.addons.k8s.io-pre-k8s-1.6
    Location              addons/dns-controller.addons.k8s.io/pre-k8s-1.6.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-kube-dns.addons.k8s.io-k8s-1.6
    Location              addons/kube-dns.addons.k8s.io/k8s-1.6.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-kube-dns.addons.k8s.io-pre-k8s-1.6
    Location              addons/kube-dns.addons.k8s.io/pre-k8s-1.6.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-limit-range.addons.k8s.io
    Location              addons/limit-range.addons.k8s.io/v1.5.0.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-rbac.addons.k8s.io-k8s-1.8
    Location              addons/rbac.addons.k8s.io/k8s-1.8.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-storage-aws.addons.k8s.io-v1.6.0
    Location              addons/storage-aws.addons.k8s.io/v1.6.0.yaml

  ManagedFile/clevandowski-kops.k8s.local-addons-storage-aws.addons.k8s.io-v1.7.0
    Location              addons/storage-aws.addons.k8s.io/v1.7.0.yaml

  Route/0.0.0.0/0
    RouteTable            name:clevandowski-kops.k8s.local
    CIDR                  0.0.0.0/0
    InternetGateway       name:clevandowski-kops.k8s.local

  RouteTable/clevandowski-kops.k8s.local
    VPC                   name:clevandowski-kops.k8s.local
    Shared                false
    Tags                  {Name: clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned, kubernetes.io/kops/role: public}

  RouteTableAssociation/eu-west-3a.clevandowski-kops.k8s.local
    RouteTable            name:clevandowski-kops.k8s.local
    Subnet                name:eu-west-3a.clevandowski-kops.k8s.local

  SSHKey/kubernetes.clevandowski-kops.k8s.local-19:7f:d4:48:b9:69:39:0c:c6:e1:eb:90:70:b4:02:13
    KeyFingerprint        73:39:3e:e0:4c:1e:9c:06:46:79:6a:3e:75:89:2d:07

  Secret/admin

  Secret/kube

  Secret/kube-proxy

  Secret/kubelet

  Secret/system:controller_manager

  Secret/system:dns

  Secret/system:logging

  Secret/system:monitoring

  Secret/system:scheduler

  SecurityGroup/api-elb.clevandowski-kops.k8s.local
    Description           Security group for api ELB
    VPC                   name:clevandowski-kops.k8s.local
    RemoveExtraRules      [port=443]
    Tags                  {Name: api-elb.clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned}

  SecurityGroup/masters.clevandowski-kops.k8s.local
    Description           Security group for masters
    VPC                   name:clevandowski-kops.k8s.local
    RemoveExtraRules      [port=22, port=443, port=2380, port=2381, port=4001, port=4002, port=4789, port=179]
    Tags                  {kubernetes.io/cluster/clevandowski-kops.k8s.local: owned, Name: masters.clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local}

  SecurityGroup/nodes.clevandowski-kops.k8s.local
    Description           Security group for nodes
    VPC                   name:clevandowski-kops.k8s.local
    RemoveExtraRules      [port=22]
    Tags                  {Name: nodes.clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned}

  SecurityGroupRule/all-master-to-master
    SecurityGroup         name:masters.clevandowski-kops.k8s.local
    SourceGroup           name:masters.clevandowski-kops.k8s.local

  SecurityGroupRule/all-master-to-node
    SecurityGroup         name:nodes.clevandowski-kops.k8s.local
    SourceGroup           name:masters.clevandowski-kops.k8s.local

  SecurityGroupRule/all-node-to-node
    SecurityGroup         name:nodes.clevandowski-kops.k8s.local
    SourceGroup           name:nodes.clevandowski-kops.k8s.local

  SecurityGroupRule/api-elb-egress
    SecurityGroup         name:api-elb.clevandowski-kops.k8s.local
    CIDR                  0.0.0.0/0
    Egress                true

  SecurityGroupRule/https-api-elb-0.0.0.0/0
    SecurityGroup         name:api-elb.clevandowski-kops.k8s.local
    CIDR                  0.0.0.0/0
    Protocol              tcp
    FromPort              443
    ToPort                443

  SecurityGroupRule/https-elb-to-master
    SecurityGroup         name:masters.clevandowski-kops.k8s.local
    Protocol              tcp
    FromPort              443
    ToPort                443
    SourceGroup           name:api-elb.clevandowski-kops.k8s.local

  SecurityGroupRule/master-egress
    SecurityGroup         name:masters.clevandowski-kops.k8s.local
    CIDR                  0.0.0.0/0
    Egress                true

  SecurityGroupRule/node-egress
    SecurityGroup         name:nodes.clevandowski-kops.k8s.local
    CIDR                  0.0.0.0/0
    Egress                true

  SecurityGroupRule/node-to-master-tcp-1-2379
    SecurityGroup         name:masters.clevandowski-kops.k8s.local
    Protocol              tcp
    FromPort              1
    ToPort                2379
    SourceGroup           name:nodes.clevandowski-kops.k8s.local

  SecurityGroupRule/node-to-master-tcp-2382-4000
    SecurityGroup         name:masters.clevandowski-kops.k8s.local
    Protocol              tcp
    FromPort              2382
    ToPort                4000
    SourceGroup           name:nodes.clevandowski-kops.k8s.local

  SecurityGroupRule/node-to-master-tcp-4003-65535
    SecurityGroup         name:masters.clevandowski-kops.k8s.local
    Protocol              tcp
    FromPort              4003
    ToPort                65535
    SourceGroup           name:nodes.clevandowski-kops.k8s.local

  SecurityGroupRule/node-to-master-udp-1-65535
    SecurityGroup         name:masters.clevandowski-kops.k8s.local
    Protocol              udp
    FromPort              1
    ToPort                65535
    SourceGroup           name:nodes.clevandowski-kops.k8s.local

  SecurityGroupRule/ssh-external-to-master-0.0.0.0/0
    SecurityGroup         name:masters.clevandowski-kops.k8s.local
    CIDR                  0.0.0.0/0
    Protocol              tcp
    FromPort              22
    ToPort                22

  SecurityGroupRule/ssh-external-to-node-0.0.0.0/0
    SecurityGroup         name:nodes.clevandowski-kops.k8s.local
    CIDR                  0.0.0.0/0
    Protocol              tcp
    FromPort              22
    ToPort                22

  Subnet/eu-west-3a.clevandowski-kops.k8s.local
    VPC                   name:clevandowski-kops.k8s.local
    AvailabilityZone      eu-west-3a
    CIDR                  172.20.32.0/19
    Shared                false
    Tags                  {Name: eu-west-3a.clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned, kubernetes.io/role/elb: 1, SubnetType: Public}

  VPC/clevandowski-kops.k8s.local
    CIDR                  172.20.0.0/16
    EnableDNSHostnames    true
    EnableDNSSupport      true
    Shared                false
    Tags                  {Name: clevandowski-kops.k8s.local, KubernetesCluster: clevandowski-kops.k8s.local, kubernetes.io/cluster/clevandowski-kops.k8s.local: owned}

  VPCDHCPOptionsAssociation/clevandowski-kops.k8s.local
    VPC                   name:clevandowski-kops.k8s.local
    DHCPOptions           name:clevandowski-kops.k8s.local

Must specify --yes to apply changes

Cluster configuration has been created.

Suggestions:
 * list clusters with: kops get cluster
 * edit this cluster with: kops edit cluster clevandowski-kops.k8s.local
 * edit your node instance group: kops edit ig --name=clevandowski-kops.k8s.local nodes
 * edit your master instance group: kops edit ig --name=clevandowski-kops.k8s.local master-eu-west-3a

Finally configure your cluster with: kops update cluster clevandowski-kops.k8s.local --yes

[guest@be9549c44462 bin]$ echo $?
0
```

```
[guest@be9549c44462 bin]$ kops edit cluster ${NAME}
Edit cancelled, no changes made.
```

```
[guest@be9549c44462 bin]$ kops update cluster ${NAME} --yes
I0704 14:03:11.144078     204 apply_cluster.go:456] Gossip DNS: skipping DNS validation
I0704 14:03:11.314124     204 executor.go:91] Tasks: 0 done / 77 total; 30 can run
I0704 14:03:11.753938     204 vfs_castore.go:731] Issuing new certificate: "apiserver-aggregator-ca"
I0704 14:03:11.841973     204 vfs_castore.go:731] Issuing new certificate: "ca"
I0704 14:03:12.564409     204 executor.go:91] Tasks: 30 done / 77 total; 24 can run
I0704 14:03:12.891173     204 vfs_castore.go:731] Issuing new certificate: "kube-proxy"
I0704 14:03:12.981431     204 vfs_castore.go:731] Issuing new certificate: "kops"
I0704 14:03:12.997902     204 vfs_castore.go:731] Issuing new certificate: "kube-scheduler"
I0704 14:03:13.018177     204 vfs_castore.go:731] Issuing new certificate: "kubelet"
I0704 14:03:13.021055     204 vfs_castore.go:731] Issuing new certificate: "apiserver-proxy-client"
I0704 14:03:13.089463     204 vfs_castore.go:731] Issuing new certificate: "kubelet-api"
I0704 14:03:13.165597     204 vfs_castore.go:731] Issuing new certificate: "kubecfg"
I0704 14:03:13.219371     204 vfs_castore.go:731] Issuing new certificate: "apiserver-aggregator"
I0704 14:03:13.457411     204 vfs_castore.go:731] Issuing new certificate: "kube-controller-manager"
I0704 14:03:13.616171     204 executor.go:91] Tasks: 54 done / 77 total; 19 can run
I0704 14:03:13.888001     204 launchconfiguration.go:341] waiting for IAM instance profile "masters.clevandowski-kops.k8s.local" to be ready
I0704 14:03:13.937490     204 launchconfiguration.go:341] waiting for IAM instance profile "nodes.clevandowski-kops.k8s.local" to be ready
I0704 14:03:24.358452     204 executor.go:91] Tasks: 73 done / 77 total; 3 can run
I0704 14:03:25.077620     204 vfs_castore.go:731] Issuing new certificate: "master"
I0704 14:03:25.237511     204 executor.go:91] Tasks: 76 done / 77 total; 1 can run
I0704 14:03:25.586091     204 executor.go:91] Tasks: 77 done / 77 total; 0 can run
I0704 14:03:25.671410     204 update_cluster.go:291] Exporting kubecfg for cluster
kops has set your kubectl context to clevandowski-kops.k8s.local

Cluster is starting.  It should be ready in a few minutes.

Suggestions:
 * validate cluster: kops validate cluster
 * list nodes: kubectl get nodes --show-labels
 * ssh to the master: ssh -i ~/.ssh/id_rsa admin@api.clevandowski-kops.k8s.local
 * the admin user is specific to Debian. If not using Debian please use the appropriate user based on your OS.
 * read about installing addons at: https://github.com/kubernetes/kops/blob/master/docs/addons.md.

[guest@be9549c44462 bin]$ echo $?
0
```

```
[guest@be9549c44462 bin]$ kubectl get nodes
Unable to connect to the server: dial tcp: lookup api-clevandowski-kops-k8s-2s9plg-793609504.eu-west-3.elb.amazonaws.com on 8.8.8.8:53: no such host
```

```
[guest@be9549c44462 bin]$ kops validate cluster
Using cluster from kubectl context: clevandowski-kops.k8s.local

Validating cluster clevandowski-kops.k8s.local


unexpected error during validation: error listing nodes: Get https://api-clevandowski-kops-k8s-2s9plg-793609504.eu-west-3.elb.amazonaws.com/api/v1/nodes: dial tcp: lookup api-clevandowski-kops-k8s-2s9plg-793609504.eu-west-3.elb.amazonaws.com on 8.8.8.8:53: no such host
```

```
[guest@be9549c44462 bin]$ kops validate cluster
Using cluster from kubectl context: clevandowski-kops.k8s.local

Validating cluster clevandowski-kops.k8s.local

INSTANCE GROUPS
NAME      ROLE  MACHINETYPE MIN MAX SUBNETS
master-eu-west-3a Master  t2.large  1 1 eu-west-3a
nodes     Node  t2.large  2 2 eu-west-3a

NODE STATUS
NAME            ROLE  READY
ip-172-20-32-194.eu-west-3.compute.internal master  True
ip-172-20-45-30.eu-west-3.compute.internal  node  True
ip-172-20-50-188.eu-west-3.compute.internal node  True

Your cluster clevandowski-kops.k8s.local is ready
```

```
[guest@be9549c44462 bin]$ kubectl get nodes
NAME                                          STATUS    ROLES     AGE       VERSION
ip-172-20-32-194.eu-west-3.compute.internal   Ready     master    4m        v1.9.6
ip-172-20-45-30.eu-west-3.compute.internal    Ready     node      3m        v1.9.6
ip-172-20-50-188.eu-west-3.compute.internal   Ready     node      3m        v1.9.6
```

```
[guest@be9549c44462 bin]$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
secret/kubernetes-dashboard-certs created
serviceaccount/kubernetes-dashboard created
role.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
deployment.apps/kubernetes-dashboard created
service/kubernetes-dashboard created
```

```
[guest@be9549c44462 bin]$ kubectl cluster-info
Kubernetes master is running at https://api-clevandowski-kops-k8s-2s9plg-793609504.eu-west-3.elb.amazonaws.com
KubeDNS is running at https://api-clevandowski-kops-k8s-2s9plg-793609504.eu-west-3.elb.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

```
[guest@be9549c44462 bin]$ kops get secrets kube --type secret -oplaintext
Using cluster from kubectl context: clevandowski-kops.k8s.local

fB5tvmmmumSC4O9NLkCWQt5ov9W9qnHw

```

```
[guest@be9549c44462 bin]$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.7.0.yaml
deployment.extensions/heapster created
service/heapster created
serviceaccount/heapster created
clusterrolebinding.rbac.authorization.k8s.io/heapster created
role.rbac.authorization.k8s.io/system:pod-nanny created
rolebinding.rbac.authorization.k8s.io/heapster-binding created
```

```
[guest@be9549c44462 bin]$ cat source-kops-env.sh 
#!/bin/bash

export AWS_PROFILE=$KOPS_USER
export NAME=clevandowski-kops.k8s.local
export KOPS_STATE_STORE=s3://$KOPS_USER-state-store
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
```

```
[guest@be9549c44462 bin]$ kops delete cluster --name $NAME --yes
TYPE      NAME                      ID
autoscaling-config  master-eu-west-3a.masters.clevandowski-kops.k8s.local-20180704140313      master-eu-west-3a.masters.clevandowski-kops.k8s.local-20180704140313
autoscaling-config  nodes.clevandowski-kops.k8s.local-20180704140313          nodes.clevandowski-kops.k8s.local-20180704140313
autoscaling-group master-eu-west-3a.masters.clevandowski-kops.k8s.local         master-eu-west-3a.masters.clevandowski-kops.k8s.local
autoscaling-group nodes.clevandowski-kops.k8s.local             nodes.clevandowski-kops.k8s.local
dhcp-options    clevandowski-kops.k8s.local               dopt-b71854de
iam-instance-profile  masters.clevandowski-kops.k8s.local             masters.clevandowski-kops.k8s.local
iam-instance-profile  nodes.clevandowski-kops.k8s.local             nodes.clevandowski-kops.k8s.local
iam-role    masters.clevandowski-kops.k8s.local             masters.clevandowski-kops.k8s.local
iam-role    nodes.clevandowski-kops.k8s.local             nodes.clevandowski-kops.k8s.local
instance    master-eu-west-3a.masters.clevandowski-kops.k8s.local         i-0fb812b53e0142d24
instance    nodes.clevandowski-kops.k8s.local             i-0053daef6b1254bd4
instance    nodes.clevandowski-kops.k8s.local             i-0e7fad4454c2ca414
internet-gateway  clevandowski-kops.k8s.local               igw-775bd91e
keypair     kubernetes.clevandowski-kops.k8s.local-19:7f:d4:48:b9:69:39:0c:c6:e1:eb:90:70:b4:02:13  kubernetes.clevandowski-kops.k8s.local-19:7f:d4:48:b9:69:39:0c:c6:e1:eb:90:70:b4:02:13
load-balancer   api.clevandowski-kops.k8s.local               api-clevandowski-kops-k8s-2s9plg
route-table   clevandowski-kops.k8s.local               rtb-f05b0f99
security-group    api-elb.clevandowski-kops.k8s.local             sg-58f32530
security-group    masters.clevandowski-kops.k8s.local             sg-0af02662
security-group    nodes.clevandowski-kops.k8s.local             sg-fefe2896
subnet      eu-west-3a.clevandowski-kops.k8s.local              subnet-32e48a5b
volume      a.etcd-events.clevandowski-kops.k8s.local           vol-05b57442f3016295e
volume      a.etcd-main.clevandowski-kops.k8s.local             vol-09cd5e852119c8733
vpc     clevandowski-kops.k8s.local               vpc-f54c0b9c

load-balancer:api-clevandowski-kops-k8s-2s9plg  ok
keypair:kubernetes.clevandowski-kops.k8s.local-19:7f:d4:48:b9:69:39:0c:c6:e1:eb:90:70:b4:02:13  ok
internet-gateway:igw-775bd91e still has dependencies, will retry
instance:i-0fb812b53e0142d24  ok
autoscaling-group:master-eu-west-3a.masters.clevandowski-kops.k8s.local ok
autoscaling-group:nodes.clevandowski-kops.k8s.local ok
instance:i-0e7fad4454c2ca414  ok
instance:i-0053daef6b1254bd4  ok
iam-instance-profile:masters.clevandowski-kops.k8s.local  ok
iam-instance-profile:nodes.clevandowski-kops.k8s.local  ok
iam-role:masters.clevandowski-kops.k8s.local  ok
iam-role:nodes.clevandowski-kops.k8s.local  ok
autoscaling-config:master-eu-west-3a.masters.clevandowski-kops.k8s.local-20180704140313 ok
autoscaling-config:nodes.clevandowski-kops.k8s.local-20180704140313 ok
subnet:subnet-32e48a5b  still has dependencies, will retry
volume:vol-05b57442f3016295e  still has dependencies, will retry
volume:vol-09cd5e852119c8733  still has dependencies, will retry
security-group:sg-0af02662  still has dependencies, will retry
security-group:sg-fefe2896  still has dependencies, will retry
security-group:sg-58f32530  still has dependencies, will retry
Not all resources deleted; waiting before reattempting deletion
  volume:vol-05b57442f3016295e
  vpc:vpc-f54c0b9c
  subnet:subnet-32e48a5b
  internet-gateway:igw-775bd91e
  security-group:sg-58f32530
  volume:vol-09cd5e852119c8733
  security-group:sg-fefe2896
  security-group:sg-0af02662
  dhcp-options:dopt-b71854de
  route-table:rtb-f05b0f99
subnet:subnet-32e48a5b  still has dependencies, will retry
internet-gateway:igw-775bd91e still has dependencies, will retry
volume:vol-09cd5e852119c8733  still has dependencies, will retry
volume:vol-05b57442f3016295e  still has dependencies, will retry
security-group:sg-0af02662  still has dependencies, will retry
security-group:sg-fefe2896  still has dependencies, will retry
security-group:sg-58f32530  still has dependencies, will retry
Not all resources deleted; waiting before reattempting deletion
  vpc:vpc-f54c0b9c
  subnet:subnet-32e48a5b
  internet-gateway:igw-775bd91e
  security-group:sg-58f32530
  volume:vol-09cd5e852119c8733
  security-group:sg-fefe2896
  security-group:sg-0af02662
  dhcp-options:dopt-b71854de
  route-table:rtb-f05b0f99
  volume:vol-05b57442f3016295e
subnet:subnet-32e48a5b  still has dependencies, will retry
internet-gateway:igw-775bd91e still has dependencies, will retry
volume:vol-09cd5e852119c8733  ok
volume:vol-05b57442f3016295e  ok
security-group:sg-58f32530  still has dependencies, will retry
security-group:sg-fefe2896  still has dependencies, will retry
security-group:sg-0af02662  ok
Not all resources deleted; waiting before reattempting deletion
  internet-gateway:igw-775bd91e
  security-group:sg-58f32530
  security-group:sg-fefe2896
  dhcp-options:dopt-b71854de
  route-table:rtb-f05b0f99
  vpc:vpc-f54c0b9c
  subnet:subnet-32e48a5b
internet-gateway:igw-775bd91e ok
subnet:subnet-32e48a5b  ok
security-group:sg-58f32530  ok
security-group:sg-fefe2896  ok
route-table:rtb-f05b0f99  ok
vpc:vpc-f54c0b9c  ok
dhcp-options:dopt-b71854de  ok
Deleted kubectl config for clevandowski-kops.k8s.local

Deleted cluster: "clevandowski-kops.k8s.local"
```


