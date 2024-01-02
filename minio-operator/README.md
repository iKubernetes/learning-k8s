# MinIO Operator

MinIO is a Kubernetes-native high performance object store with an S3-compatible API. The MinIO Kubernetes Operator supports deploying MinIO Tenants onto private and public cloud infrastructures (“Hybrid” Cloud).

![MinIO Operator 架构图](https://min.io/docs/minio/kubernetes/upstream/_images/OperatorsComponent-Diagram1.png)

## 安装MinIO Operator

安装和初始化MinIO Operator，要借助于kubectl minio插件进行。

### 安装kubectl minit插件

运行如下命令首先安装该插件。

```yaml
MINIO_VERSION='5.0.11'
curl-LO https://github.com/minio/operator/releases/download/${MINIO_VERSION}/kubectl-minio_5.0.11_linux_amd64 -o kubectl-minio
chmod +x kubectl-minio
mv kubectl-minio /usr/local/bin/
```

### 部署MinIO Operator

“kubectl minio init”命令可用于进行Operator初始化，运行该命令，可自动在Kubernetes集群上部署MinIO Operator。相关组件默认部署于mini-operator名称空间，若需要使用自定义的名称空间，可在如下命令上附加“--namespace”选项。

```bash 
kubectl minio init
```

如下命令可打印MinIO Operator各组件的部署状况，待所有Pod转为Running状态后，即可使用其服务。

```bash 
kubectl get all --namespace minio-operator
```

该命令会产生类似如下的输出，其中的console Pod提供了Web UI。

```
NAME                                 READY   STATUS    RESTARTS   AGE
pod/console-75dc7dc944-8p2fj         1/1     Running   0          16m
pod/minio-operator-5c58f669b-nrtwc   1/1     Running   0          16m
pod/minio-operator-5c58f669b-zvktt   1/1     Running   0          16m

NAME               TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
service/console    ClusterIP      10.110.195.107   <none>        9090/TCP,9443/TCP     16m
service/operator   ClusterIP      10.98.236.253    <none>        4221/TCP              16m
service/sts        ClusterIP      10.101.217.75    <none>        4223/TCP              16m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/console          1/1     1            1           16m
deployment.apps/minio-operator   2/2     2            2           16m

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/console-75dc7dc944         1         1         1       16m
replicaset.apps/minio-operator-5c58f669b   2         2         2       16m
```

### 访问UI

修改service/console的类型为NodePort或LoadBalancer，即可从相应的端点访问Operator Console。下面的命令，将其修改成了LoadBalancer类型。

```bash 
kubectl patch service console -p '{"spec": {"type": "LoadBalancer"}}' -n minio-operator
```

修改完成后，运行如下命令，打印获得的LoadBalancer IP。

```bash
kubectl get service/console -n minio-operator -o json | jq -r '.status'
```

随后，即可通过该IP地址的9090或9443端口访问Operator Console。例如Console的认证信息，可通过如下命令打印。

```bash 
kubectl get secret/console-sa-secret -n minio-operator -o json | jq -r '.data.token' | base64 -d
```



## 管理Tenant

Each MinIO Tenant represents an independent MinIO Object Store within the Kubernetes cluster. The following diagram describes the architecture of a MinIO Tenant deployed into Kubernetes:

![](https://github.com/minio/operator/raw/master/docs/images/architecture.png)
