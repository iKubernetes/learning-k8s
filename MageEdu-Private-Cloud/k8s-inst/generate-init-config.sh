#!/bin/bash
# export addresses and other vars
set -a
K8S_API_ENDPOINT=kubeapi.magedu.com
K8S_API_ADDVERTISE_IP=192.168.10.6
K8S_VERSION=1.28.2
K8S_CLUSTER_NAME=kubernetes
K8S_SERVICE_MODE=iptables
K8S_POD_SUBNET="10.244.0.0/16"
K8S_SERVICE_SUBNET="10.96.0.0/12"
K8S_DNS_DOMAIN="cluster.local"
set +a

envsubst < kubeadm-init-config.tmpl.yaml > kubeadm-init-config.yaml
