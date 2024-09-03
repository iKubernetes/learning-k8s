# 在Kubernetes上部署Kuboard

Kuboard是一款免费的Kubernetes管理工具，提供了丰富的功能，结合已有或新建的代码仓库、镜像仓库、CI/CD工具等，可以便捷的搭建一个生产可用的Kubernetes容器云平台，轻松管理和运行云原生应用。也可以直接将Kuboard安装到现有的Kubernetes集群，通过Kuboard提供的Kubernetes RBAC管理界面，将Kubernetes提供的能力开放给开发/测试团队。

项目地址：[Kuboard](https://kuboard.cn)

## 部署Kuboard-v3

以下给出两个部署kuboard-v3的方式，其中“临时存储”不依赖于任何StorageClass即可直接进行部署，而“基于OpenEBS存储”的方式，则依赖于部署可用的OpenEBS环境，且提供了支持“ReadWriteOnce”的“openebs-hostpath”的存储类和支持“ReadWriteMany”的存储类“openebs-rwx”。

#### 临时存储

运行下面的命令，使用本示例中提供的资源配置文件，将Kuboard以单实例形式部署到Kubernetes集群上。

```bash
kubectl apply -f https://raw.githubusercontent.com/iKubernetes/learning-k8s/master/Kuboard/kuboard-ephemeral/kuboard-v3.yaml
```

而后，运行如下命令，查看Kuboard Pod的相关状态。

```bash
kubectl get pods -n kuboard
```

上面命令的运行结果应该类似如下内容所示。

```
NAME                          READY   STATUS    RESTARTS   AGE
kuboard-v3-795d76b98f-b8zxs   1/1     Running   0          2m
```

接下来即可通过kuboard-v3 Service的NodePort访问其Web应用，在该部署示例中，它使用固定的30080端口。

#### 基于OpenEBS存储

运行下面的命令，使用本示例中提供的资源配置文件，将Kuboard以单实例形式部署到Kubernetes集群上。它依赖于事先部署可用的OpenEBS存储。

```bash
kubectl apply -f https://raw.githubusercontent.com/iKubernetes/learning-k8s/master/Kuboard/kuboard-persistent/kuboard-v3.yaml
```

而后，运行如下命令，查看Kuboard Pod的相关状态。

```bash
kubectl get pods -n kuboard
```

接下来即可通过kuboard-v3 Service的NodePort访问其Web应用，在该部署示例中，它使用固定的30080端口。

## 通过Ingress开放Kuboard

相关的配置示例如下，它依赖于一个可用的Ingress Nginx。

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kuboard-v3
  namespace: kuboard
spec:
  ingressClassName: nginx
  rules:
  - host: kuboard.magedu.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: kuboard-v3
            port:
              number: 80
        pathType: Prefix
```

将上面的配置保存于配置文件中，例如kuboard-ingress.yaml，即可运行如下命令创建Ingress资源至Kubernetes集群上。

```bash
kubectl apply -f kuboard-ingress.yaml
```

了解相关的Ingress资源的简要信息，并确保将kuboard.magedu.com域名解析至相关的IP地址上，即可通过浏览器发起访问。Kuboard默认的管理员用户为“admin/Kuboard123”。

## 部署示例应用

首先创建example名称空间。

```bash
kubectl create namespace example
```

而后，将示例应用配置文件中定义的资源对象创建到Kubernetes集群上即可。

```bash
kubectl apply -f kuboard_example.yaml
```

