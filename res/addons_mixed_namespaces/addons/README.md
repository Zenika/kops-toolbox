# ADDONS

## Token nécessaire pour accéder aux applications du cluster en tant qu'admin

```
kops get secrets kube --type secret -oplaintext
```

## Dashboard kubernetes

* Démarrer le dashboard

```
$ kubectl apply -f res/addons/kubernetes-dashboard.yaml
```

* Récupérer l'URL du dashboard

```
kubectl cluster-info
```

* Se connecter au dashboard : 

```
https://<kubernetes-master-hostname>/ui
```

* Récupérer le token d'authentification du dashboard

```
kops get secrets admin --type secret -oplaintext
```


## Logging stack EFK

```
kubectl apply -f res/addons/logging-elasticsearch/logging-elasticsearch.yaml
```

Trouver les URL pour les services ES et Kibana: 
```
kubectl cluster-info
```
