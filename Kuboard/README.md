# 在Kubernetes上部署Kuboard

Kuboard是一款免费的Kubernetes管理工具，提供了丰富的功能，结合已有或新建的代码仓库、镜像仓库、CI/CD工具等，可以便捷的搭建一个生产可用的Kubernetes容器云平台，轻松管理和运行云原生应用。也可以直接将Kuboard安装到现有的Kubernetes集群，通过Kuboard提供的Kubernetes RBAC管理界面，将Kubernetes提供的能力开放给开发/测试团队。

项目地址：[Kuboard](https://kuboard.cn)

## 部署Kuboard v3

运行下面的命令，使用本示例中提供的资源配置文件，将Kuboard以单实例形式部署到Kubernetes集群上。

```bash
kubectl apply -f https://raw.githubusercontent.com/iKubernetes/learning-k8s/master/Kuboard/deploy.yaml
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

## 通过Ingress开放Kuboard

相关的配置示例如下，它依赖于一个可用的Ingress Nginx。

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kuboard
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



