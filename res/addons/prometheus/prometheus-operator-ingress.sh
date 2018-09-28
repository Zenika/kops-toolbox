#!/bin/bash

cat << COINCOIN

---

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: grafana
  namespace: tooling
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: grafana.$CLUSTER_DOMAIN
    http:
      paths:
      - path: /
        backend:
          serviceName: grafana
          servicePort: 3000
COINCOIN