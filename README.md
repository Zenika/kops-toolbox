# kops-toolbox

## Prérequis

* docker (version 17.09+)

## Paramétrage de l'utilisateur Kops

Pour des raisons de sécurité, les utilisateurs admin ne peuvent plus avoir de clés API.
Par conséquent, l'utilisateur Kops ne peut pas être créé par un utilisateur Admin via les API. Il faut donc le créer manuellement via l'IHM AWS.

### Création du groupe Kops

Accéder via l'IHM à la fonctionnalité d'ajout de groupe :
Services > IAM > Groups, action "Create New Group"

Créer le groupe via l'IHM 

Le nom du groupe sera référencé par la variable d'environnement KOPS_GROUP et sera référencé dans cette doc par "my-kops-group"

### Définition des policies "Custom" pour le groupe

Accéder via l'IHM à la fonctionnalité d'ajout de policies :
Services > IAM > Policies, action "Create policy"

Pour chaque fichier dans le répertoire aws-policies, créer une policy ayant le nom du fichier et copier-coller le contenu du fichier dans l'onglet json

* CustomIAMFullAccess
* CustomEC2FullAccess2
* CustomEC2FullAccess

### Attachement des policies au groupe

Accéder via l'IHM à la fonctionnalité d'ajout de groupe :
Services > IAM > Groups > "my-kops-group", onglet "Permissions"

Attacher les policies suivantes:
* CustomIAMFullAccess
* CustomEC2FullAccess
* CustomEC2FullAccess2
* AmazonS3FullAccess
* AmazonVPCFullAccess
* AmazonRoute53FullAccess

## Création du user Kops

Accéder via l'IHM à la fonctionnalité d'ajout d'utilisateur :
Services > IAM > Users, action "Add user"

* Etape 1/4 - Set user details
** Définir "user-name"
** Access Type: Cocher "Programmatic Access" afin de créer une "Access Key" pour les API

* Etape 2/4 - Set permissions
** Sélectionner "Add user to group"
** Cocher le nom du groupe préalablement créé avec ses policies

* Etape 3/4 - Review
Vérifier les infos avant création du user

* Etape 4/4 - User créé, récupération des infos
Récupérer l'Access Key ID et l'Access Key Secret

Le nom du user sera référencé par la variable d'environnement KOPS_USER et sera référencé dans cette doc par "my-kops-user"

* Ajouter le user "my-kops-user" dans ~/.aws/credentials

Voici un exemple de contenu pour le user "my-kops-user":

```
[my-kops-user]
aws_access_key_id = COINCOINCOINCOINCOIN
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

## Démarrage de la toolbox

* Déclarer les variables d'environnement KOPS_USER, KOPS_GROUP, AWS_REGION, CLUSTER_NAME et DOCKER_REPO
```
$ export KOPS_USER=my-kops-user
$ export KOPS_GROUP=my-kops-group
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

* Et aussi avec votre répertoire .ssh
```
$ ln -s ~/.ssh run/.ssh
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
Accéder au dashboard : \<url du cluster\>/ui

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


