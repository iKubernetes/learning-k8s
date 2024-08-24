# OpenEBS存储

OpenEBS是CAS存储机制的著名开源实现之一，由CNCF孵化。OpenEBS目前主要维护有4.x和3.x两个主版本，4.x版本几乎是完全重构的实现，同3.x系列差别巨大，因此，OpenEBS项目业已将3.x系列称为“Legacy”版本。读者可根据需要自行选择部署特定的版本。

> 4.x系列版本相关的helm repo及部署说明：https://openebs.github.io/openebs/

## 部署OpenEBS

### 部署v4.1版本的OpenEBS

运行如下命令，即可部署基础的OpenEBS 4.1版本的存储系统，它支持基于hostpath和lvm的local pv，默认部署在openebs名称空间。

```bash 
kubectl apply -f https://raw.githubusercontent.com/iKubernetes/learning-k8s/master/OpenEBS/deployment/openebs-localpv-lvm-4.1.yaml
```

### 部署3.10版本

运行如下命令，即可部署基础的OpenEBS 3.10版本的系统，支持基于hostpath的local pv，默认部署在openebs名称空间。

```bash
kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
```

### 部署3.10版本（第2种部署方式）

```bash 
kubectl apply -f https://raw.githubusercontent.com/openebs/openebs/v3.10.0/k8s/openebs-operator.yaml
```

而后，则要创建StorageClass资源对象openebs-hostpath，注意按需修改其节点上的存储目录路径。示例配置如下。

```yaml
---
# Source: openebs/charts/localpv-provisioner/templates/hostpath-class.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: openebs-hostpath
  annotations:
    openebs.io/cas-type: local
    cas.openebs.io/config: |
      - name: StorageType
        value: "hostpath"
      - name: BasePath
        value: "/var/openebs/local"
provisioner: openebs.io/local
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
```

运行如下命令即可直接创建相关的存储类。

```bash 
kubectl apply -f https://raw.githubusercontent.com/iKubernetes/learning-k8s/master/OpenEBS/deployment/storageclass-openebs-hostpath.yaml
```

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



## 部署和测试使用Jiva PV

以下操作，仅适用于3.x版本的OpenEBS。

### 部署Jiva Operator

部署Jiva Operator。

```bash
kubectl apply -f https://openebs.github.io/charts/jiva-operator.yaml
```

查看相关的Pod的创建状态。

```bash
kubectl get pods -n openebs -l name=jiva-operator
```

> 提示：如需要用到Jiva数据引擎，则需要事先在每个节点上部署iSCSI client。Ubuntu系统的安装命令如下。
>
> ```bash 
> sudo apt-get update
> sudo apt-get install open-iscsi
> sudo systemctl enable --now iscsid
> ```

### 测试使用Jiva PV

创建JivaVolumePolicy，而后创建Jiva相关的StorageClass，即可从该StorageClass中请求创建PVC。

## 部署和测试使用LVM PV

### 部署LVM Opertor

仅3.x版本的OpenEBS需要执行该步骤。

```bash
kubectl apply -f https://openebs.github.io/charts/lvm-operator.yaml
```

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

> 说明：本小节仅适用于3.x系列的OpenEBS。

OpenEBS Dynamic NFS Provider能够为OpenEBS的多种数据引擎上的卷添加支持多路读写（RWX）的功能，但相关的组件需要单独部署。

```bash
kubectl apply -f https://openebs.github.io/charts/nfs-operator.yaml
```

### 测试使用NFS PV

创建NFS PV相关的使用StorageClass，即可从该StorageClass中请求创建PVC。



## Helm方式部署

若要部署4.x系列的OpenEBS，也可基于如下命令，快速进行部署。

首先，设置Helm仓库。

```bash
helm repo add openebs https://openebs.github.io/openebs
helm repo update
```

而后，运行如下命令，即可完成部署。

```bash
helm install openebs --namespace openebs openebs/openebs --create-namespace
```

若用不到MayaStor，可改用如下命令进行部署。

```bash
helm install openebs --namespace openebs openebs/openebs --set engines.replicated.mayastor.enabled=false --create-namespace
```

若用不到MayaStor和zfs localpv，可改用如下命令进行部署。

```bash
helm install openebs --namespace openebs openebs/openebs --set engines.replicated.mayastor.enabled=false \
            --set engines.local.zfs.enabled=false --create-namespace
```



## 版权声明

本文档由[马哥教育](http://www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。
