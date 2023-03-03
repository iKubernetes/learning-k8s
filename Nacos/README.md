# 部署Nacos的资源配置文件

### 依赖的前提：
- StorageClass/nfs-csi

### 部署步骤 

部署MySQL

```bash
kubectl create namespace nacos
kubectl apply -f deploy/01-nacos-mysql-pvc-nfs.yaml -n nacos
```

部署Nacos

```bash
kubectl apply -f deploy/02-nacos-pvc-nfs.yaml -n nacos
```
