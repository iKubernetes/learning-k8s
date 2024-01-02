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

### 测试使用Local PV LVM

创建Local PV LVM相关的使用StorageClass，即可从该StorageClass中请求创建PVC。另外，Local PV LVM卷还支持扩容和快照等功能。

## 部署OpenEBS Dynamic NFS Provider

OpenEBS Dynamic NFS Provider能够为OpenEBS的多种数据引擎上的卷添加支持多路读写（RWX）的功能，但相关的组件需要单独部署。

```bash
kubectl apply -f https://openebs.github.io/charts/nfs-operator.yaml
```

### 测试使用NFS PV

创建NFS PV相关的使用StorageClass，即可从该StorageClass中请求创建PVC。

## 版权声明

本文档由[马哥教育](http://www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。
