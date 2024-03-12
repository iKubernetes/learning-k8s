## 部署redis

可以部署的独立的名称空间，也可以部署在目标应用的名称空间中，如redis。

#### 部署redis

首先，运行如下命令，创建名称空间。

```bash
kubectl create namespace redis
```

接着，运行如下命令，部署redis replication cluster。

```bash
kubectl apply -f . -n redis
```

部署完成后，其master的访问地址为“redis-0.redis.redis.svc”，客户端可通过此地址向redis发起存取请求。

#### 部署sentinel（可选）

最后，部署redis sentinel。此为可选步骤。

```bash
kubectl apply -f ./sentinel/ -n redis
```

### Grafana Dashboard

Dashboard ID: 763


## 版权声明

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
