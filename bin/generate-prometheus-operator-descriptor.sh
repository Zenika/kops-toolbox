#!/bin/bash

echo -e "Generating the prometheus-operator yaml descriptor with cluster domain $CLUSTER_DOMAIN"

cat ~/res/addons/prometheus/prometheus-operator-first-part.yaml > ~/res/addons/prometheus/prometheus-operator-with-ingress.yaml
~/res/addons/prometheus/prometheus-operator-ingress.sh >> ~/res/addons/prometheus/prometheus-operator-with-ingress.yaml

