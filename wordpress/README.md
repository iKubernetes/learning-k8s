# Wordpress 部署示例

下面分两种情况进行部署说明，第一种是没有持久化存储的示例环境，第二种是基于PVC卷具有持久存储能力的环境。

### Ephemeral

```bash
kubectl apply -f mysql-ephemeral
kubectl apply -f wordpress-ephemeral
```



### Depends on NFS-CSI Driver and NFS Server

```bash
kubectl apply -f mysql/
kubectl apply -f wordpress/
kubectl apply -f nginx/
```

