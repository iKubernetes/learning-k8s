# 部署MySQL主从复制集群

依赖的环境：支持PV动态置备的StorageClass/nfs-csi;

### 部署过程

```bash
kubectl create namespace mysql
kubectl apply ./ -n mysql
```

### 访问入口

读请求：mysql-read.mysql.svc.cluster.local

写请求：mysql-0.mysql.mysql.svc.cluster.local



