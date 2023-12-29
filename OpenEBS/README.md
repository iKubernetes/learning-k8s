# OpenEBS存储

OpenEBS是CAS存储机制的著名实现之一，由CNCF孵化。

### 部署OpenEBS

运行如下命令，即可部署基础的OpenEBS系统，默认部署在openebs名称空间。

```bash 
kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
```

若需要支持Jiva、cStor、Local PV ZFS和Local PV LVM等数据引擎，还需要额外部署相关的组件。例如，运行如下命令，即可部署Jiva CSI。

```bash
kubectl apply -f https://openebs.github.io/charts/jiva-operator.yaml
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

