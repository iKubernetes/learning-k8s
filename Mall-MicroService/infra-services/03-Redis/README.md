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

### 版权声明

本示例由[马哥教育](http://www.magedu.com)原创，允许自由转载，商用必须经由马哥教育的书面同意。
