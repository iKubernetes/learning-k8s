# Loki

### values文件

本示例中提供了两个values文件

- loki-values.yaml：启用了s3存储的文件，依赖于“minio.minio.svc.cluster.local”所指向的MinIO Service，且需要用到三个bucket，这些bucket需要事先创建完成
  - chunks：存储chunks文件的bucket
  - ruler：存储rules文件的bucket
  - admin
- loki-with-alert-values.yaml：除了具有前一个values文件的特点外，它还基于端点“http://alertmanager:9093”调用AlertManager Service

### 部署Loki Server

第一步，添加Helm仓库，并更新索引信息。

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```



第二步，创建Release。

若无须调用AlertManager，运行如下命令即可。

```bash
helm upgrade --install --values loki-values.yaml loki grafana/loki --namespace loki --create-namespace
```

若城要调用AlertManager，则应该事先部署AlertManager，而后再运行如下命令。

```bash
helm upgrade --install --values loki-with-alert-values.yaml loki grafana/loki --namespace loki --create-namespace
```

