# Kubernetes集群初始化

本示例用于快速拉起一个学习用的Kubernetes集群环境。

## 部署Kubernetes集群

### 1. 部署kubeadm等程序包

首次部署Kubernetes集群时，需要先编辑[脚本文件](cluster-install.sh)，配置指定Master节点的IP地址，以及各工作节点的IP地址匹配实际环境。

```
MASTER_IP='192.168.10.6'
NODE_01_IP='192.168.10.11'
NODE_02_IP='192.168.10.12'
NODE_03_IP='192.168.10.13'
```

> 提示：若工作节点数量不为三个，还需要按需修改如下用于生成ansibles inventory hosts文件的内容。
>
> ```
> MASTER_IP='192.168.10.6'
> NODE_01_IP='192.168.10.11'
> NODE_02_IP='192.168.10.12'
> NODE_03_IP='192.168.10.13'
> ```

若此前已经完成过该步骤，则无须重复执行。

### 2. 初始化集群

本示例分别为使用flannel、calico和cilium网络插件准备了专用的ansible playbook，用户需要根据要选用的插件，执行如下对应的一个小节即可。

#### (1) Flannel

flannel支持vxlan、vxlan with directrouting和host-gw等三种后端，其配置参数如下，相关内容位于[该文件](install-k8s-flannel.yaml)中。

```yaml
- hosts: master
  vars:
    # Kubernetes集群的版本，要与部署的kubeadm程序包的版本保持一致
    k8s_version: "v1.31.0"
    # 要使用的子网，flannel默认使用“10.244.0.0/16”
    pod_cidr: "10.244.0.0/16"
    # 要使用的service子网，kubeadm默认使用“10.96.0.0/12”
    service_cidr: "10.96.0.0/12"
    # mode，支持routing和tunneling两种
    mode: "tunneling"
    # 隧道协议，这里仅支持vxlan
    tunnel_protocol: "vxlan"
    # 是否在vxlan上使用的directrouting    
    vxlan_directrouting: "false"
    # 下载Image的mirror站点，默认为registry.k8s.io
    image_repo: "registry.aliyuncs.com/google_containers"
```

配置完成后，运行如下命令，即可完成部署。

```bash
ansible-playbook install-k8s-flannel.yaml
```

#### (2) Calico

calico支持vxlan和ipip隧道模式，以及同bgp路由学习的Underlay网络路由模式。本示例中的配置，支持如下三种选择。

- vxlan：设置mode为“tunneling”，同时tunnel_protocol为“VXLAN”
- ipip：设置mode为“tunneling”，同时tunnel_protocol为“IPIP”
- ipip和bgp混合：设置mode为“routing”，同时tunnel_protocol为“IPIP”

其配置参数如下，相关内容位于[该文件](install-k8s-calico.yaml)中。

```yaml
- hosts: master
  vars:
    k8s_version: "v1.31.0"
    pod_cidr: "10.244.0.0/16"
    pod_cidr_block_size: "24"
    service_cidr: "10.96.0.0/12"
    # mode: routing, tunneling
    mode: "tunneling"
    # tunnel protocol: IPIP, VXLAN
    tunnel_protocol: "IPIP"
    image_repo: "registry.aliyuncs.com/google_containers"
```

配置完成后，运行如下命令，即可完成部署。

```bash
ansible-playbook install-k8s-calico.yaml
```

#### (3) Cilium

Cilium支持vxlan和geneve隧道模式，以及同bgp路由学习的Underlay网络路由模式。默认使用vxlan隧道模式。

配置完成后，运行如下命令，即可完成部署。

```bash
ansible-playbook install-k8s-cilium.yaml
```

### 3. 重新启动集群

部署完成后，需要重新启动集群节点，以完成初始化。

```bash
ansible-playbook reboot-system.yaml
```

重新启动完成后，确认所有节点进入“Ready”状态，集群即初步部署完成。

```bash
~$ kubectl get nodes
NAME                      STATUS   ROLES           AGE   VERSION
k8s-master01.magedu.com   Ready    control-plane   66s   v1.31.0
k8s-node01.magedu.com     Ready    <none>          66s   v1.31.0
k8s-node02.magedu.com     Ready    <none>          66s   v1.31.0
k8s-node03.magedu.com     Ready    <none>          66s   v1.31.0
```

### 4. 部署必要的附件

#### (1) MetalLB

部署MetalLB，为LoadBalancer类型的Service提供本地实现。部署文档在[这里](https://metallb.universe.tf/installation/)。待MetalLB的所有Pod就绪后，需要创建地址池才能用于为LoadBalancer Service提供地址，相关的配置方式请参考[这里](../MetalLB/)。修改好配置后，运行如下命令，即可创建地址池。

```bash
cd learning-k8s/
kubectl apply -f MetalLB/
```

#### (2) Ingress Nginx

Ingress Nginx是由Kubernetes社区维护的Ingress Controller的实现，其部署文档在[这里](https://kubernetes.github.io/ingress-nginx/deploy/)。部署完成后，待所有Pod转为就绪状态，随后即可基于Ingress发布服务至集群外部。

或者也可以使用用下的helm命令进行部署，且启用内置的Metrics。

```bash
helm install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.metrics.enabled=true \
    --set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
    --set-string controller.podAnnotations."prometheus\.io/port"="10254" \
    --create-namespace
```

#### (3) OpenEBS

OpenEBS是面向Kubernetes的开源存储系统，CAS风格。其部署文档在[这里](https://openebs.io/docs/quickstart-guide/installation)，也可参考这里的[文档](../OpenEBS/)进行部署。

#### (4) Prometheus指标系统

Prometheus和Prometheus Adpater可用于为Kubernetes提供指标系统，具体的部署方式可参考这里的[文档](https://github.com/iKubernetes/k8s-prom/tree/master/helm)进行部署。

目前，Prometheus Adapter v0.12版本，可为Kubernetes提供核心指标API（metrics.k8s.io）和自定义指标API（custom.metrics.k8s.io），因此，它可直接替代Metrics Server的作用。

#### (5) Kuboard集群面板

Kuboard是Kubernetes的知名Dashboard项目，部署方式可参考这里的[文档](https://github.com/iKubernetes/learning-k8s/tree/master/Kuboard)进行部署。



## 关于Containerd的配置

> 重要提示：**registry.mirrors**和**registry.configs**配置段将在containerd v2中弃用，其配置要修改为类似如下描述的配置格式。

具体的说明，在[这里](https://github.com/containerd/containerd/blob/main/docs/cri/registry.md)。



## 版权声明

本文档由[马哥教育](http://www.magedu.com/)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。
