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

NB : bien vérifier les ARN dans les fichiers des politiques. Ces politiques ne donnent actuellement des autorisations et interdictions que si l'on possède un certain ID de compte. Il faudrait regarder comment adapter ça.

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
    * Définir "user-name"
    * Access Type: Cocher "Programmatic Access" afin de créer une "Access Key" pour les API

* Etape 2/4 - Set permissions
    * Sélectionner "Add user to group"
    * Cocher le nom du groupe préalablement créé avec ses policies

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

###Progression par étapes : 

* [Première étape : cluster basique](Step01_basic_cluster/README.md)

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

## Installation et configuration de Jenkins X


* Pour lancer l'assistant d'installation de Jenkins X : 
```
$ jx install
```

* Plusieurs questions seront posées par l'outil CLI : 
    * Tout d'abord, sélectionner son cloud provider (ici AWS)
    ```
    ? Cloud Provider aws
    ```
    * Puis la configuration git à utiliser
    ```
    ? Please enter the name you wish to use with git:  Rude-Monkey
    ? Please enter the email address you wish to use with git:  vgilles@et.esiea.fr
    ```
    * Ensuite, il sera demandé d'installer un ingress controller : accepter
    ```
    ? No existing ingress controller found in the kube-system namespace, shall we install one? Yes
    ```
    * Lorsqu'il est demandé d'associer un domaine au cluster, refuser (à moins d'en avoir un, bien évidemment)
    ```
    On AWS we recommend using a custom DNS name to access services in your kubernetes cluster to ensure you can use all of your availability zones
    If you do not have a custom DNS name you can use yet you can register a new one here: https://console.aws.amazon.com/route53/home?#DomainRegistration:

    ? Would you like to register a wildcard DNS ALIAS to point at this ELB address?  No
    ```
    * N'ayant pas de domaine, jx va proposer de résoudre l'IP du cluster et de l'utiliser en tant que domaine avec une wildcard. Accepter les deux prochaines requêtes
    ```
    The Ingress address acb1e4034a6df11e882ae0a0ad56e6ec-2c458d7f578f5fa4.elb.eu-west-3.amazonaws.com is not an IP address. We recommend we try resolve it to a public IP address and use that for the domain to access services externally.
    ? Would you like wait and resolve this address to an IP address and use it for the domain? Yes

    Waiting for acb1e4034a6df11e882ae0a0ad56e6ec-2c458d7f578f5fa4.elb.eu-west-3.amazonaws.com to be resolvable to an IP address...
    acb1e4034a6df11e882ae0a0ad56e6ec-2c458d7f578f5fa4.elb.eu-west-3.amazonaws.com resolved to IP 52.47.128.128
    You can now configure a wildcard DNS pointing to the new loadbalancer address 52.47.128.128
    ```
    ```
    If you don't have a wildcard DNS setup then setup a new CNAME and point it at: 52.47.128.128.nip.io then use the DNS domain in the next input...
    ? Domain 52.47.128.128.nip.io
    nginx ingress controller installed and configured
    ```
    * Configuration des accès GitHub : génération d'une clé API et injection du token dans Jenkins X
    ```
    Lets set up a git username and API token to be able to perform CI/CD

    ? GitHub user name: Rude-Monkey
    To be able to create a repository on GitHub we need an API Token
    Please click this URL https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo

    Then COPY the token and enter in into the form below:

    ? API Token: ****************************************
    ```
    * Configuration de Jenkins : génération de token et injection dans Jenkins X
    ```
    Jenkins X deployments ready in namespace jx


        ********************************************************

            NOTE: Your admin password is: hidenavy

        ********************************************************

        Getting Jenkins API Token
    using url http://jenkins.jx.52.47.128.128.nip.io/me/configure
    unable to automatically find API token with chromedp using URL http://jenkins.jx.52.47.128.128.nip.io/me/configure
    Please go to http://jenkins.jx.52.47.128.128.nip.io/me/configure and click Show API Token to get your API Token
    Then COPY the token and enter in into the form below:

    ? API Token: ********************************
    ```
    * Jenkins X va ensuite créer deux repositories sur GitHub pour les environnements staging et production, ainsi que les différents webhooks nécessaires
    ```
    About to create repository environment-gamblerlizard-staging on server https://github.com with user Rude-Monkey

    Creating repository Rude-Monkey/environment-gamblerlizard-staging
    Creating git repository Rude-Monkey/environment-gamblerlizard-staging
    Pushed git repository to https://github.com/Rude-Monkey/environment-gamblerlizard-staging

    Created environment staging
    Created Jenkins Project: http://jenkins.jx.52.47.128.128.nip.io/job/Rude-Monkey/job/environment-gamblerlizard-staging/

    Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!

    Creating github webhook for Rude-Monkey/environment-gamblerlizard-staging for url http://jenkins.jx.52.47.128.128.nip.io/github-webhook/
    Using git provider GitHub at https://github.com

    About to create repository environment-gamblerlizard-production on server https://github.com with user Rude-Monkey

    Creating repository Rude-Monkey/environment-gamblerlizard-production
    Creating git repository Rude-Monkey/environment-gamblerlizard-production
    Pushed git repository to https://github.com/Rude-Monkey/environment-gamblerlizard-production

    Created environment production
    Created Jenkins Project: http://jenkins.jx.52.47.128.128.nip.io/job/Rude-Monkey/job/environment-gamblerlizard-production/

    Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!

    Creating github webhook for Rude-Monkey/environment-gamblerlizard-production for url http://jenkins.jx.52.47.128.128.nip.io/github-webhook/

    Jenkins X installation completed successfully
    ```



## Nettoyage après shutdown du cluster

### Désinstallation de Jenkins X
* Supprimer les repositories : 
```
$ jx delete repo
```
* Supprimer l'équilibrateur de charge : 
Dans l'interface d'administration AWS, dans le service EC2, aller dans "équilibrateurs de charge" sous l'onglet "Équilibrage de charge".
Celui à supprimer porte des balises de type : 
```
"kubernetes.io/service-name : kube-system/jxing-nginx-ingress-controller"
"KubernetesCluster : vincent.gilles.kops.k8s.local"
```

### Suppression et nettoyage du cluster
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


