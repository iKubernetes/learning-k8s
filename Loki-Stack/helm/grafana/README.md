### 部署Grafana



添加仓库。

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```



部署Grafana

```bash
helm upgrade --install --values grafana-values.yaml grafana grafana/grafana --namespace loki --create-namespace
```



