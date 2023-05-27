# Helm Harbor

helm repo add harbor https://helm.goharbor.io

kubeclt create namespace harbor

helm install harbor -f harbor-values.yaml harbor/harbor -n harbor
