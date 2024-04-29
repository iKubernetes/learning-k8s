# Loki



添加仓库。

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```



基于现有的值文件，创建Release。

```bash
cd loki
helm upgrade --install --values loki-values.yaml loki grafana/loki --namespace loki --create-namespace
```



