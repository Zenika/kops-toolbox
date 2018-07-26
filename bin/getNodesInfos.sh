#!/bin/bash

#kubectl get nodes  --template=$'{{range .items}}name: {{.metadata.name}}\ntype: {{index .metadata.labels "kubernetes.io/role"}}\n{{range .status.addresses}}{{if eq .type "ExternalDNS"}}externalAddress: {{.address}}\n{{end}}{{end}}---------------------------------------------------\n{{end}}'
kubectl get nodes  --template=$'{{range .items}}name: {{.metadata.name}}\nrole: {{index .metadata.labels "kubernetes.io/role"}}\n{{range .status.addresses}}{{.type}}: {{.address}}\n{{end}}---------------------------------------------------\n{{end}}'
