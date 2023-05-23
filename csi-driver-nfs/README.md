# 部署CSI-NFS-Deriver

必要的步骤说明：

1. 需要事先有可用的NFS服务，且能够满足CSI-NFS-Driver的使用要求；
2. 在Kubernetes集群上部署NFS CSI Driver；
3. 在Kubernetes集群上创建StorageClass资源，其provisioner为nfs.csi.k8s.io，而parameters.server要指向准备好的NFS Server的访问入口；
4. 测试使用；

## 在Kubernetes集群上部署NFS Server

- 运行如下命令，在Kubernetes集群上部署一个可用的NFS服务；

```bash
kubectl create namespace nfs
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/nfs-provisioner/nfs-server.yaml --namespace nfs
```

## Install NFS CSI Driver  on a kubernetes cluster

支持两种部署方式：远程部署和本地部署，前者是指直接从远程仓库中获取部署配置文件完成的部署，而后者则需要首先克隆csi-driver-nfs项目的仓库至本地，并在克隆而来的本地项目目录中进行部署。

目前，NFS CSI Driver项目维护有多个不同的版本，部署前需要首先确定要选择使用的版本。需要特别说明的是，4.0及以上版本中，在csi-nfs-controller和csi-nfs-node相关的Pod的配置中的dnsPolicy都使用了“Default”，但又使用了spec.hostNetwork配置，这种配置中，此两者相关的Pod将无法使用ClusterDNS解析集群上的服务。因此，为了能够同此前的部署NFS Server协同，我们需要事先修改dnsPolicy的值为“ClusterFirstWithHostNet”。

为了方便大家的使用，本仓库中直接基于v4.1.0和v4.2.0版本分别生成了一个将dnsPolicy的值为“ClusterFirstWithHostNet”的配置示例。以v4.2.0为例，相关的文件在[deploy](https://github.com/iKubernetes/learning-k8s/tree/master/csi-driver-nfs/deploy)/[03-csi-driver-nfs-4.2](https://github.com/iKubernetes/learning-k8s/tree/master/csi-driver-nfs/deploy/03-csi-driver-nfs-4.2)目录下。本示例将直接基于这些文件完成NFS CSI Driver的部署。

 - local install（基于当前项目的部署，其默认配置已经修改dnsPolicy）
```console
git clone https://github.com/iKubernetes/learning-k8s.git
cd learning-k8s
kubectl apply -f csi-driver-nfs/deploy/03-csi-driver-nfs-4.2/
```

- check pods status:
```console
kubectl -n kube-system get pod -o wide -l 'app in (csi-nfs-node,csi-nfs-controller)'
```

example output:

```console
NAME                                  READY   STATUS    RESTARTS   AGE    IP            NODE                      NOMINATED NODE   READINESS GATES
csi-nfs-controller-59bcd59954-v2vb6   3/3     Running   0          10m   172.29.9.13   k8s-node03.magedu.com     <none>           <none>
csi-nfs-node-66q4k                    3/3     Running   0          10m   172.29.9.13   k8s-node03.magedu.com     <none>           <none>
csi-nfs-node-7572x                    3/3     Running   0          10m   172.29.9.11   k8s-node01.magedu.com     <none>           <none>
csi-nfs-node-95j7s                    3/3     Running   0          10m   172.29.9.1    k8s-master01.magedu.com   <none>           <none>
csi-nfs-node-h6gq7                    3/3     Running   0          10m   172.29.9.12   k8s-node02.magedu.com     <none>           <none>
```


## Storage Class Usage (Dynamic Provisioning)

 -  Create a storage class
 > change `server`, `share` with your existing NFS server address and share name
```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: nfs.csi.k8s.io
parameters:
  #server: nfs-server.default.svc.cluster.local
  server: nfs-server.nfs.svc.cluster.local
  share: /
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - hard
  - nfsvers=4.1
```

若需要在创建完StorageClass后将其设置为默认，可使用类似如下命令进行。

```bash
kubectl patch storageclass nfs-csi -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

取消某StorageClass的默认设定，则将类似上面命令中的annotation的值修改为false即可。

 - 创建一个PVC进行测试

```console
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/pvc-nfs-csi-dynamic.yaml
```

## Create a deployment
```console
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/deployment.yaml
```
