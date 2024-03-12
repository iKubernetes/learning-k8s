# 部署SkyWalking及UI

首先，创建专用的名称空间，以部署Skywalking及相关组件。

```bash 
kubectl create namespace tracing
```

而后，运行如下命令，部署Skywalking OAP。需要说明的是，下面命令中用到的配置文件，依赖于部署在elastic名称空间中的elasticsearch服务。

```bash 
kubectl apply -f 01-skywalking-oap.yaml -n tracing
```

最后，运行如下命令，部署Skywalking UI。

```bash 
kubectl apply -f 01-skywalking-ui.yaml -n tracing
```

