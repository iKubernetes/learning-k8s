# 在Kubernetes集群上部署Gitlab
依赖的环境：
- 基于nfs-csi的存储服务，以及相关的StorageClass，资源名称为nfs-csi
- Ingress Nginx Controller

### 部署（二选一）

非持久化存储，不依赖于事先配置的StorageClass/nfs-csi。

```
kubectl apply -f deploy/
```

持久化存储。

```bash
kubectl apply -f deploy-persistent/
