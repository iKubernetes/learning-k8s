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
