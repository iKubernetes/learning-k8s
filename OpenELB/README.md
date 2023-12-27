# OpenELB简单应用

OpenELB 是一个开源的云原生负载均衡器实现，可以在基于裸金属服务器、边缘以及虚拟化的 Kubernetes 环境中使用 LoadBalancer 类型的 Service 对外暴露服务。

### 核心功能

- BGP模式和二层网络模式下的负载均衡
- ECMP路由和负载均衡
- IP地址池管理
- 基于CRD来管理BGP配置

### Install OpenELB Using kubectl

运行如下命令，使用kubectl部署OpenELB至Kubernetes集群。

```bash
kubectl apply -f https://raw.githubusercontent.com/openelb/openelb/master/deploy/openelb.yaml
```

确认openelb-manager Pod已经处于Running状态，且容器已经Ready。

```bash
kubectl get pods -n openelb-system
```

其输出的结果应该类似如下所示。

```
NAME                              READY   STATUS      RESTARTS   AGE
openelb-admission-create-kn4fg    0/1     Completed   0          5m
openelb-admission-patch-9jfxs     0/1     Completed   2          5m
openelb-keepalive-vip-7brjl       1/1     Running     0          4m
openelb-keepalive-vip-nfpgm       1/1     Running     0          4m
openelb-keepalive-vip-vsgkx       1/1     Running     0          4m
openelb-manager-d6df4dfc4-2q4cm   1/1     Running     0          5m
```

### 配置示例：layer2模式

下面的示例创建了一个Eip资源对象，它提供了一个地址池给LoadBalancer Service使用。

```yaml
apiVersion: network.kubesphere.io/v1alpha2
kind: Eip
metadata:
    name: eip-pool
    annotations:
      eip.openelb.kubesphere.io/is-default-eip: "true"
      # 指定当前Eip作为向LoadBalancer Server分配地址时使用默认的eip对象；
spec:
    address: 172.29.5.51-172.29.5.60
    # 地址范围，也可以使用单个IP，或者带有掩码长度的网络地址；
    protocol: layer2
    # 要使用的OpenELB模式，支持bgp、layer2和vip三种，默认为bgp；
    interface: enp1s0
    # OpenELB侦听ARP或NDP请求时使用的网络接口名称，仅layer2模式下有效；
    disable: false
```

创建完成后，可使用如命令验证。

```bash
kubectl get eip eip-pool -o yaml
```

输出结果应该类似如下所示。

```
apiVersion: network.kubesphere.io/v1alpha2
kind: Eip
metadata:
  annotations:
    eip.openelb.kubesphere.io/is-default-eip: "true"
  creationTimestamp: "2023-03-01T05:49:53Z"
  finalizers:
  - finalizer.ipam.kubesphere.io/v1alpha1
  generation: 2
  name: eip-pool
spec:
  address: 172.29.5.51-172.29.5.60
  interface: enp1s0
  protocol: layer2
status:
  firstIP: 172.29.5.51
  lastIP: 172.29.5.60
  poolSize: 10
  ready: true
  usage: 0
  v4: true
```

创建Deployment和LoadBalancer Service，测试地址池是否已经能正常向Service分配LoadBalancer IP。

```bash
kubectl create deployment demoapp --image=ikubernetes/demoapp:v1.0 --replicas=2
kubectl create service loadbalancer demoapp --tcp=80:80
```

运行如下命令，查看service资源对象demoapp上是否自动获得了External IP。

```bash
kubectl get service demoapp
```

其结果应该类似如下内容，这表明EIP地址分配已经能够正常进行。

```
NAME      TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
demoapp   LoadBalancer   10.97.7.114   172.29.5.51   80:30072/TCP   8m
```

随后，即可于集群外部的客户端上通过IP地址“172.29.5.51”对demoapp服务发起访问测试。

### 故障排查

因为Kubernetes版本等方面的原因，部署EIP资源时遇到类似如下错误信息。

Error from server (InternalError): error when creating "eip-pool.yaml": Internal error occurred: failed calling webhook "validate.eip.network.kubesphere.io": failed to call webhook: Post "https://openelb-admission.openelb-system.svc:443/validate-network-kubesphere-io-v1alpha2-eip?timeout=10s": EOF

若要忽略该类信息，可通过运行如下两个命令关闭相关的校验功能，然后再重新创建EIP资源。

```bash
kubectl delete -A ValidatingWebhookConfiguration openelb-admission
kubectl delete -A MutatingWebhookConfiguration openelb-admission
```

### 清理

删除部署的测试目的Deployment和LoadBalancer Server。

```bash
kubectl delete service/demoapp deployment/demoapp
```

