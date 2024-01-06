# MetalLB简单应用

A network load-balancer implementation for Kubernetes using standard routing protocols.

MetalLB核心功能的实现依赖于两种机制：

- 地址分配：基于指定的地址池进行分配；
- 对外公告：让集群外部的网络了解新分配的IP地址，MetalLB使用ARP、NDP或BGP实现

### 部署MetalLB

kube-proxy工作于ipvs模式时，必须要使用严格ARP（StrictARP）模式，因此，若有必要，先运行如下命令，配置kube-proxy。

```bash
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
```

随后，运行如下命令，即可部署MetalLB至Kubernetes集群。

```bash
METALLB_VERSION='v0.13.12'
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml
```

### 创建地址池

下面是一个IPAddressPool资源示例。

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: localip-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.29.7.51-172.29.7.80
  autoAssign: true
  avoidBuggyIPs: true
```

### 创建二层公告机制

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: localip-pool-l2a
  namespace: metallb-system
spec:
  ipAddressPools:
  - localip-pool
  interfaces:
  - enp1s0
```



### 注意事项

#### MetalLB on OpenStack

You can run a Kubernetes cluster on OpenStack VMs, and use MetalLB as the load balancer. However you have to disable OpenStack’s ARP spoofing protection if you want to use L2 mode. You must disable it on all the VMs that are running Kubernetes.

By design, MetalLB’s L2 mode looks like an ARP spoofing attempt to OpenStack, because we’re announcing IP addresses that OpenStack doesn’t know about. There’s currently no way to make OpenStack cooperate with MetalLB here, so we have to turn off the spoofing protection entirely.



## 版权声明

本文档由[马哥教育](http://www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。

