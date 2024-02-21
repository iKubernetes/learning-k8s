# OpenEBS存储

OpenEBS是CAS存储机制的著名实现之一，由CNCF孵化。

## 部署OpenEBS

运行如下命令，即可部署基础的OpenEBS系统，默认部署在openebs名称空间。

```bash 
kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
```

若需要支持Jiva、cStor、Local PV ZFS和Local PV LVM等数据引擎，还需要额外部署相关的组件。例如，运行如下命令，即可于openebs名称空间中部署Jiva CSI Controller及CSI Plugin。

```bash
kubectl apply -f https://openebs.github.io/charts/jiva-operator.yaml
```

运行如下命令，即可部署Local PV LVM相关的Controller和CSI Plugin。需要说明的是，Local PV LVM相关的Pod部署于kube-system名称空间。

```bash
kubectl apply -f https://openebs.github.io/charts/lvm-operator.yaml
```

> 提示：如需要用到Jiva数据引擎，则需要事先在每个节点上部署iSCSI client。Ubuntu系统的安装命令如下。
>
> ```bash 
> sudo apt-get update
> sudo apt-get install open-iscsi
> sudo systemctl enable --now iscsid
> ```

### 测试使用OpenEBS Local PV

基于默认的StorageClass，请求创建PVC资源即可，下面是一个示例。

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
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

### 测试使用Jiva PV

创建JivaVolumePolicy，而后创建Jiva相关的StorageClass，即可从该StorageClass中请求创建PVC。

### 测试使用Local PV using LVM

创建Local PV LVM相关的使用StorageClass，即可从该StorageClass中请求创建PVC。另外，Local PV LVM卷还支持扩容和快照等功能。

#### 部署前提

在Kubernetes集群上部署OpenEBS LVM Controller之前，需要事先满足以下几个需求：

- 所有节点安装有lvm2 utils程序包，且在内核中装载了dm-snapshot模块； 
- 配置好了可用的Volume Group，例如lvmvg；
- openebs-lvm-controller和openebs-lvm-node会部署于kube-system名称空间，请确保有权限使用名称空间

#### 创建Volume Group

在全部或准备有相关设备的节点上创建Pysical Volume和Volume Group以备使用。以“/dev/vdb1”为例，执行如下两个命令即能完成创建。

```bash 
pvcreate /dev/vdb1
vgcreate lvmvg /dev/vdb1
```

若仅在集群中的部分节点上创建了Volume Group，后面创建StorageClass时需要明确指明拥有VG的节点。

#### 部署

运行如下命令即可完成部署。

```bash 
$ kubectl apply -f https://openebs.github.io/charts/lvm-operator.yaml
```

#### 创建StorageClass

将如下配置中定义的资源对象创建于Kubernetes集群上，即可从中申请创建PVC。需要说明的是，若仅在集群中的部分节点上创建有相关的Volume Group，则需要启用后面的配置，并明确列出拥有相关VG的节点。

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: openebs-lvmpv
allowVolumeExpansion: true
parameters:
  storage: "lvm"
  volgroup: "lvmvg"
provisioner: local.csi.openebs.io
reclaimPolicy: Retain
#allowedTopologies:
#- matchLabelExpressions:
#  - key: kubernetes.io/hostname
#    values:
#      - k8s-node01.magedu.com
#      - k8s-node03.magedu.com
```





## 部署OpenEBS Dynamic NFS Provider

OpenEBS Dynamic NFS Provider能够为OpenEBS的多种数据引擎上的卷添加支持多路读写（RWX）的功能，但相关的组件需要单独部署。

```bash
kubectl apply -f https://openebs.github.io/charts/nfs-operator.yaml
```

### 测试使用NFS PV

创建NFS PV相关的使用StorageClass，即可从该StorageClass中请求创建PVC。

## 版权声明

本文档由[马哥教育](http://www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。
