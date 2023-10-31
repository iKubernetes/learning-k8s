# 部署MongoDB ReplicaSet集群

依赖条件：
- 一个支持动态PV置备的StorageClass，本示例使用”nfs-csi”
- 一个分布的Kubernetes集群

### 部署方法
直接将各配置文件创建在集群上即可，建议使用专用的namespace；

```bash
kubectl create namespace mongo
kubectl apply -f . -n mongo
```

### 查看集群状态

```bash
kubectl exec -it mongodb-0 -n mongo
mongo> rs.status()
```

## 版权声明
本示例由[马哥教育](http://www.magedu.com)原创，允许自由转载，商用必须经由马哥教育的书面同意。
