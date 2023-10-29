## 部署redis

可以部署的独立的名称空间，也可以部署在目标应用的名称空间中，如mall，本文以mall名称空间为例。

#### 部署redis

创建名称空间

```bash
kubectl create namespace mall
```

部署redis replication cluster

```bash
kubectl apply -f . -n mall
```

#### 部署sentinel（可选）

部署redis sentinel

```bash
kubectl apply -f ./sentinel/ -n mall
```

### 版权声明

本示例由[马哥教育](http://www.magedu.com)原创，允许自由转载，商用必须经由马哥教育的书面同意。
