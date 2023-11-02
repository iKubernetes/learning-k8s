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

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
