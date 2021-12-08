# 于Kubernetes集群上部署Gitlab
依赖的环境：
- 基于nfs-csi的存储服务，以及相关的StorageClass，资源名称为nfs-csi
- Ingress Nginx Controller

### 部署命令
```
kubectl apply -f deploy/
```
