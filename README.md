# kops-toolbox

## Prérequis

* docker (version 17.09+)

## Démarrage de la toolbox

* Déclarer les variables d'environnement KOPS_USER et AWS_REGION
```
$ export KOPS_USER=my-kops-user
$ export AWS_REGION=eu-west-1
$ export CLUSTER_NAME=my.kops.cluster.k8s.local
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
Il faut maintenant créer le user kops et le state-store

## Création du contexte d'utilisation

* Création du user, groupe, droits, access_key et clé ssh
```
[guest@ac7056a87f3d ~]$ create-aws-kops-user.sh
```

* Création du kops state-store
```
[guest@ac7056a87f3d ~]$ create-aws-s3-kops-state-store.sh
```

* Activer le user kops comme utilisateur courant sur AWS

Note: Ne pas oublier le "." devant la commande pour sourcer
```
[guest@ac7056a87f3d ~]$ source source-kops-env.sh
[guest@ac7056a87f3d ~]$ aws iam get-user
USER  arn:aws:iam::301517625970:user/clevandowski-kops  2018-07-04T21:47:19Z  / AIDAJQFNXUY23HFPTJ2G4 clevandowski-kops
[guest@ac7056a87f3d ~]$ echo $KOPS_USER 
clevandowski-kops
```
Le user indiqué par la commande "aws iam get-user" doit être le user kops défini par KOPS_USER

## Nettoyage après shutdown du cluster

* Suppression du kops state-store
```
[guest@ac7056a87f3d ~]$ delete-aws-s3-kops-state-store.sh
```

* Suppression du user, groupe, droits, access_key et clé ssh
```
[guest@ac7056a87f3d ~]$ delete-aws-kops-user.sh
```

