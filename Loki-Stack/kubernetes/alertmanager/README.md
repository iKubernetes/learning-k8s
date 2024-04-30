# AlertManager

添加AlertManager相关的Helm仓库。

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm update
```



运行如下命令，部署AlertManager于loki名称空间。

```bash
helm upgrade --install --values alertmanager-values.yaml alertmanager prometheus-community/alertmanager \
             --namespace loki --create-namespace
```

