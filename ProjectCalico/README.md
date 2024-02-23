# Calico BGP RR配置示例

在100个节点规模以上的Calico集群环境中，为提升iBGP的效率，通常应该建立Router Reflector。

### 示例环境

本示例中的Kubernetes集群共有四个节点。

- k8s-master01.magedu.com，地址为172.29.7.1
- k8s-node01.magedu.com，地址为172.29.7.11
- k8s-node02.magedu.com，地址为172.29.7.12
- k8s-node03.magedu.com，地址为172.29.7.13

Calico的默认配置中，各节点间建立的是full-mesh拓扑。下面是在k8s-master01.magedu.com运行“calicoctl node status”命令打印的相关信息。

```
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.29.7.11  | node-to-node mesh | up    | 09:25:26 | Established |
| 172.29.7.12  | node-to-node mesh | up    | 09:25:26 | Established |
| 172.29.7.13  | node-to-node mesh | up    | 09:25:26 | Established |
+--------------+-------------------+-------+----------+-------------+
```

相关的节点间默认使用64512自治系统号，下面的结果由命令“calicoctl get nodes -o wide”所打印。

```
NAME                           ASN            IPV4             IPV6   
k8s-master01.magedu.com      (64512)     172.29.7.1/16           
k8s-node01.magedu.com        (64512)     172.29.7.11/16          
k8s-node02.magedu.com        (64512)     172.29.7.12/16          
k8s-node03.magedu.com        (64512)     172.29.7.13/16       
```



在后面的测试步骤中，我们会先配置k8s-master01成为Router Reflector，而后再调整k8s-node01.magedu.com也成为RR，以提供冗余能力。

> 重要提醒：配置过程中，Calico网络可能会出现短暂的通信中断，生产环境中，请务必确保在维护窗口期内进行操作。

### 配置启用BGP RR

配置过程大致分为三个步骤。

- 配置选定的节点成为Route Reflector
- 配置Calico BGP，禁用full-mesh
- 配置的有节点仅将选定作为RR的节点作为BGP Peer

#### 创建Route Reflector

集群中的任意Calico Node都可配置成为Route Reflector。不过，要想成为Route Reflector，这些选定的节点必须要有一个配置好的Cluster ID，这个ID通常是一个未被使用的IPv4地址，例如224.0.99.1。

我们首先选定k8s-master01.magedu.com作为集群中的第一个RR。运行如下命令，通过添加相应的注解信息即可配置其Cluster ID。

~# kubectl annotate node k8s-master01.magedu.com projectcalico.org/RouteReflectorClusterID=244.0.99.1

> 提示：若Calico使用的是独立的ectd存储，则需要运行的命令是“calicoctl patch node k8s-master01.magedu.com -p '{"spec": {"bgp": {"routeReflectorClusterID": "244.0.99.1"}}}'”。

为了从众多节点中标识出RR主机，通常还要为其添加可用于过滤的标识，例如节点标签。于是，运行如下命令，为选定的k8s-master01.magedu.com添加节点标签。

~# kubectl label node k8s-master01.magedu.com route-reflector='true'

随后，创建BGPPeer资源对象，配置RR的BGP Peer参数。

```yl
apiVersion: crd.projectcalico.org/v1
kind: BGPPeer
metadata:
  name: peer-with-route-reflectors
spec:
  # 节点标签选择器，定义当前配置要生效到的目标节点
  nodeSelector: all()
  # 该节点要请求与之建立BGP Peer的节点标签选择器，用于过滤和选定远端节点
  peerSelector: route-reflector == 'true'
```

运行如下命令，将如上配置中定义的BGPPeer对象创建到Kubernetes集群上。

~# kubectl apply -f bgppeer-with-rr.yaml

#### 禁用Full-mesh

创建BGPConfiguration对象，设定必要的配置参数。下面是一个示例，它保存于文件bgpconfiguration-default.yaml中。

```yaml
apiVersion: crd.projectcalico.org/v1
kind: BGPConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Info
  # 是否启用full-mesh模式，默认为true
  nodeToNodeMeshEnabled: false
  nodeMeshMaxRestartTime: 120s
  # 使用的自治系统号，默认为64512
  asNumber: 65009
  # BGP要对外通告的Service CIDR
  serviceClusterIPs:
    - cidr: 10.96.0.0/12
```

运行如下命令，将配置文件定义的对象创建到Kubernetes集群之上。

~# kubectl apply -f bgpconfiguration-default.yaml

禁用Full-mesh之后，calico的节点状态中将不再有可用的BGP Peer信息，这可以通过如下命令进行验证。

~# calicoctl node status

#### 配置同选定的RR建立BGP Peer

在k8s-master01.magedu.com运行如下命令，即可打印同该节点建立BGP Peer会话的相关的信息。因为该节点是RR节点，因而它们同集群中的其它节点都建立BGP会话。 

~# calicoctl node status

```
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.29.7.11  | node specific | up    | 07:31:18 | Established |
| 172.29.7.12  | node specific | up    | 07:31:18 | Established |
| 172.29.7.13  | node specific | up    | 07:31:18 | Established |
+--------------+---------------+-------+----------+-------------+
```

若在其它非RR节点上运行上面的命令，得到的将是类似如下的信息，下面是集群中的k8s-node01.magedu.com节点上打印的内容。

```
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.29.7.1   | node specific | up    | 07:31:18 | Established |
+--------------+---------------+-------+----------+-------------+
```

### 配置冗余的RR

再选定一个节点，为其添加“route-reflector='true'”标签，以及标识Cluster ID的注解信息，即可提升其为另一个RR。以k8s-node01.magedu.com为例，运行如下命令为其添加Cluster ID和节点标签。

~# kubectl annotate node k8s-node01.magedu.com projectcalico.org/RouteReflectorClusterID=244.0.99.1

~# kubectl label node k8s-node01.magedu.com route-reflector='true'

随后，于k8s-master01.magedu.com节点上运行如下命令，再次打印同该节点建立BGP Peer会话的相关的信息，下面的命令结果显示，第一个RR同各节点的BGP Peer信息未变。

~# calicoctl node status

```
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.29.7.11  | node specific | up    | 06:14:43 | Established |
| 172.29.7.12  | node specific | up    | 06:15:22 | Established |
| 172.29.7.13  | node specific | up    | 06:15:22 | Established |
+--------------+---------------+-------+----------+-------------+
```

同时，k8s-node01.magedu.com节点成为RR之后，它也会同整个集群中的所有节点建立起BGP Peer连接。

```
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.29.7.1   | node specific | up    | 07:43:11 | Established |
| 172.29.7.12  | node specific | up    | 07:43:09 | Established |
| 172.29.7.13  | node specific | up    | 07:43:09 | Established |
+--------------+---------------+-------+----------+-------------+
```

若在其它非RR节点上运行上面的命令，得到的将是类似如下的信息，下面是集群中的k8s-node02.magedu.com节点上打印的内容。下面的命令结果表明，当前节点同两个RR之间FTJB建立起了BGP Peer连接，因而传递路由信息的过程也有了空余路径。

```
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.29.7.1   | node specific | up    | 07:31:18 | Established |
| 172.29.7.11  | node specific | up    | 07:43:09 | Established |
+--------------+---------------+-------+----------+-------------+
```

### 配置机架专有的RR示例

下面的示例，用于为特定机架上的Server指定使用特定的RR。它仅仅是一个示例。

```yaml
apiVersion: crd.projectcalico.org/v1
kind: BGPPeer
metadata:
  name: bgppeer-rack001-tor
spec:
  # 同满足下面过滤条件的节点建立BGP Peer会话
  peerSelector: rack001-rr == 'true'
  # 配置rack001机架上的所有节点的BGP Peer属性，它依赖于事先为该机架上的所有Server打好的相关节点标签
  nodeSelector: rack == 'rack001'  
```



## 版权声明

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
