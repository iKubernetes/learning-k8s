# Deploy Wordpress

### Depends on NFS-CSI Driver and NFS Server

```bash
kubectl apply -f mysql/
kubectl apply -f wordpress/
kubectl apply -f nginx/
```

### Ephemeral

```bash
kubectl apply -f mysql-ephemeral
kubectl apply -f wordpress-ephemeral

kubectl get svc wordpress
```
