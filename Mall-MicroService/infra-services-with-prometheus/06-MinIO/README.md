# 部署MinIO

依赖于一个支持PV动态置备的StorageClass，本示例中使用nfs-csi

### 部署
将配置清单中定义的资源对象部署于Kubernetes集群上即可，需要手动指定名称空间；

```bash
kubectl create namespace minio
kubectl apply -f ./ -n minio
```

### 访问console

通过Ingress定义的Host访问，地址如下，注意要使用https协议。
https://minio.magedu.com/

默认的用户名和密码是“minioadmin/magedu.com”。


### Metrics

MinIO supports two authentication modes for Prometheus either jwt or public, by default MinIO runs in jwt mode. To allow public access without authentication for prometheus metrics set environment as follows.

```
MINIO_PROMETHEUS_AUTH_TYPE="public"
```

MinIO exports Prometheus compatible data by default as an authorized endpoint at /minio/v2/metrics/cluster.
MinIO exports Prometheus compatible data by default which is bucket centric as an authorized endpoint at /minio/v2/metrics/bucket.

```yaml
scrape_configs:
- job_name: minio-job
  metrics_path: /minio/v2/metrics/cluster
  scheme: http
  static_configs:
  - targets: ['localhost:9000']
```

```yaml
scrape_configs:
- job_name: minio-job-bucket
  metrics_path: /minio/v2/metrics/bucket
  scheme: http
  static_configs:
  - targets: ['localhost:9000']
```

```yaml
scrape_configs:
- job_name: minio-job-node
  metrics_path: /minio/v2/metrics/node
  scheme: http
  static_configs:
  - targets: ['localhost:9000']
```





## 版权声明

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
