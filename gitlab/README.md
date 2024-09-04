# 在Kubernetes集群上部署Gitlab
依赖的环境：
- 基于OpenEBS的存储服务，以及相关的StorageClass，资源名称为openebs-hostpath；或设定一个默认的StorageClass。
- Ingress Nginx Controller

### 部署（二选一）

创建用于部署GitLab的名称空间，例如gitlab。

```bash
kubectl create namespace gitlab
```

非持久化存储。

```
kubectl apply -f deploy/ -n gitlab
```

持久化存储，依赖于事先配置的StorageClass/openebs-hostpath。

```bash
kubectl apply -f deploy-persistent/ -n gitlab
```

