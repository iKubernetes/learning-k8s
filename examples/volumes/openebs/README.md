# OpenEBS简单使用示例

OpenEBS包含了很多组件，这里只部署最基本的环境，并基于Dynamic Local PV提供简单配置示例。

### 部署OpenEBS

运行如下命令，即可部署OpenEBS最基础的环境。

```bash
kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
```

检查Pod是否正常运行。

```bash
kubectl get pods -n openebs
```

OpenEBS的基础环境会创建两个StorageClass，这通过如下命令可获取到相关的信息。

```bash 
kubectl get storageclass
```

### 创建PVC

下面的配置示例中定义了一个名为openebs-local-hostpath-pvc卷请求，它会向openebs-hostpath StorageClass申请绑定一个PV。该PV会由OpenEBS动态置备，但因为延迟绑定的原因，在有Pod消费该PVC之前，PVC将一直处于Pending状态。

```YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: openebs-local-hostpath-pvc
spec:
  storageClassName: openebs-hostpath
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5G
```

### 创建Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis-with-openebs-local-hostpath
spec:
  containers:
  - name: redis
    image: redis:7-alpine
    ports:
    - containerPort: 6379
      name: redis
    volumeMounts:
    - mountPath: /data
      name: local-storage
  volumes:
  - name: local-storage
    persistentVolumeClaim:
      claimName: openebs-local-hostpath-pvc
```

