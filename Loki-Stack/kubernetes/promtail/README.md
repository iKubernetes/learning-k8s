# Promtail

添加仓库，若该仓库已经存在，则不需要重复添加。

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```



部署promtail。

```bash
helm upgrade --install promtail grafana/promtail --namespace=loki -f promtail-values.yaml --create-namespace
```



