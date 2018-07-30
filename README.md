# kops-toolbox

## Prérequis

* docker (version 17.09+)

## Démarrage de la toolbox

* Déclarer les variables d'environnement KOPS_USER, AWS_REGION, CLUSTER_NAME et DOCKER_REPO
```
$ export KOPS_USER=my-kops-user
$ export AWS_REGION=eu-west-1
$ export CLUSTER_NAME=my.kops.cluster.k8s.local
$ export DOCKER_REPO=username
```

Vous pouvez modifier les valeurs du fichier prerequisites.sh et entrer la commande suivante : 
```
$ source prerequisites.sh
```

* Créer un lien symbolique vers votre répertoire .aws
```
$ ln -s ~/.aws run/.aws
```

* Faire de même avec votre répertoire .kube
```
$ ln -s ~/.kube run/.kube
```

* Build & Run de la toolbox
Note: A lancer en sudo si vous n'êtes pas dans le groupe docker
```
$ make run
...
[guest@ac7056a87f3d ~]$
```

Vous êtes maintenant dans le container.

## Démarrage du cluster

* Pour démarrer un premier cluster :
```
$ bin/create-and-launch-cluster.sh
```
* Cela lancera un cluster avec les caractéristiques suivantes : 
    * 3 masters en haute disponibilité sur les trois zones de disponibilité de la région de Paris
    * 3 noeuds réservés à l'outillage (namespace "tooling") en haute disponibilité avec les applications suivantes : 
        * Stack EFK
        * Stack Prometheus + Grafana
        * Cockpit
    * 3 noeuds réservés à l'environnement "préprod" en haute disponibilité
    * 3 noeuds réservés à l'environnement "prod" en haute disponibilité
    * Dashboard Kubernetes déployé sur le namespace "kube-system"

* Pour accéder aux différents services, commencer par accéder au dashboard Kubernetes : 
```
$ kubectl cluster-info
Kubernetes master is running at https://api-vincent-gilles-kops-k-h32v9n-330048093.eu-west-3.elb.amazonaws.com
```
Accéder au dashboard : <url du cluster>/ui

* Récupérer les credentials : 
```
$ kops get secret admin --type secret -oplaintext
$ kops get secret kube --type secret -oplaintext
```

## Nettoyage après shutdown du cluster

* Suppression du cluster
```
$ bin/delete-cluster.sh
```

* Suppression du kops state-store
```
[guest@ac7056a87f3d ~]$ delete-aws-s3-kops-state-store.sh
```

* Suppression du user, groupe, droits, access_key et clé ssh
```
[guest@ac7056a87f3d ~]$ delete-aws-kops-user.sh
```

