# Cilium部署和使用

### 部署Kubernetes集群

部署Kubernetes集群时，在kubeadm init命令上使用“--skip-phases=addon/kube-proxy”选项，以跳过kube-proxy的安装。

```bash
kubeadm init --control-plane-endpoint kubeapi.magedu.com \
    --kubernetes-version=v1.29.2 \
    --pod-network-cidr=10.244.0.0/16 \
    --service-cidr=10.96.0.0/12 \
    --upload-certs \
    --image-repository=registry.aliyuncs.com/google_containers \
    --skip-phases=addon/kube-proxy
```



### 部署Cilium

部署Cilium：

  列出可用的Cilium版本，默认为目前最新的稳定版。

```
cilium install --list-versions 
```

打印在部署时要使用的默认配置。

```
cilium install --dry-run-helm-values
```

  示例1：使用默认的VXLAN模式，并自定义要使用的子网：

```
  cilium install \
    --set kubeProxyReplacement=strict \
    --set ipam.mode=kubernetes \
    --set ipam.operator.clusterPoolIPv4PodCIDRList=10.244.0.0/16 \
    --set ipam.Operator.ClusterPoolIPv4MaskSize=24
```

  或者使用如下与上面功能相同的命令：

```
  cilium install \
    --set kubeProxyReplacement=strict \
    --set ipam.mode=kubernetes \
    --set routingMode=tunnel \
    --set tunnelProtocol=vxlan \
    --set ipam.operator.clusterPoolIPv4PodCIDRList=10.244.0.0/16 \
    --set ipam.Operator.ClusterPoolIPv4MaskSize=24  
```





示例2：使用原生路由模式

>  提示：云上主机未必支持该模式。
>

```
  cilium install \
    --set kubeProxyReplacement=strict \
    --set ipam.mode=kubernetes \
    --set routingMode=native \
    --set ipam.operator.clusterPoolIPv4PodCIDRList=10.244.0.0/16 \
    --set ipam.Operator.ClusterPoolIPv4MaskSize=24 \
    --set ipv4NativeRoutingCIDR=10.244.0.0/16 \
    --set autoDirectNodeRoutes=true
```

  说明：开启native routing模式后，通常应该明确指定支持原生路由的网段。

#### Cilium的高级特性  

开启bpf masquerade：

--set bpf.masquerade=true

 

设置负载均衡模式：
        --set loadBalancer.mode=dsr 或者
        --set loadBalancer.mode=hybrid
                混合模式，即dsr和snat两种

  

开启DSR模式：--set autoDirectNodeRoutes=true

是否启用bpf LegacyRouting: --set bpf.hostLegacyRouting=true



#### 启用Hubble及UI

通过cilium命令启用：

```
cilium hubble enable --ui
```

部署cilium时直接启用，在cilium命令上使用如下选项即可：

```
    --set hubble.enabled="true" \
    --set hubble.listenAddress=":4244" \
    --set hubble.relay.enabled="true" \
    --set hubble.ui.enabled="true"   
```



同Prometheus对接：

```
    --set prometheus.enabled=true \
    --set operator.prometheus.enabled=true \
    --set hubble.metrics.port=9665 \
    --set hubble.metrics.enableOpenMetrics=true \
    --set metrics.enabled="{dns:query;ignoreAAAA;destinationContext=pod-short,drop:sourceContext=pod;destinationContext=pod,tcp,flow,port-distribution,icmp,http}"
    # 上面的设置，表示开启了hubble的metrics输出模式，并输出以上这些信息。默认情况下，Hubble daemonset会自动暴露metrics API给Prometheus。
```




        --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"
        #上面的设置，表示启用所有的指标。

示例：暴露所有指标的hubble配置，其它选项保持默认值即可

```
  --set prometheus.enabled=true \
  --set operator.prometheus.enabled=true \
  --set hubble.enabled=true \
  --set hubble.metrics.enableOpenMetrics=true \
  --set hubble.ui.enabled=true \
  --set hubble.relay.enabled="true" \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"
```

### 启用BGP

部署kube-router

https://docs.cilium.io/en/stable/network/kube-router/



https://raw.githubusercontent.com/cloudnativelabs/kube-router/v2.0/daemonset/generic-kuberouter-only-advertise-routes.yaml
