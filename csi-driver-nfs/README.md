

## Set up a NFS Server on a Kubernetes cluster

- To create a NFS provisioner on your Kubernetes cluster, run the following command.

```bash
kubectl create namespace nfs
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/nfs-provisioner/nfs-server.yaml --namespace nfs
```

## Install NFS CSI driver v4.1.0 version on a kubernetes cluster

- Option#1. remote install
```console
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v4.1.0/deploy/install-driver.sh | bash -s v4.1.0 --
```

- Option#2. local install
```console
git clone https://github.com/kubernetes-csi/csi-driver-nfs.git
cd csi-driver-nfs
./deploy/install-driver.sh v4.1.0 local
```

- check pods status:
```console
kubectl -n kube-system get pod -o wide -l 'app in (csi-nfs-node,csi-nfs-controller)'
```

example output:

```console
NAME                                 READY   STATUS    RESTARTS        AGE   IP            NODE                      NOMINATED NODE   READINESS GATES
csi-nfs-controller-6495ffdf79-wx7fk   3/3     Running   0               2m   172.29.6.13   k8s-node03.magedu.com     <none>           <none>
csi-nfs-node-dvn4v                    3/3     Running   0               2m   172.29.6.13   k8s-node03.magedu.com     <none>           <none>
csi-nfs-node-hcpmm                    3/3     Running   0               2m   172.29.6.12   k8s-node02.magedu.com     <none>           <none>
csi-nfs-node-j9ftq                    3/3     Running   0               2m   172.29.6.11   k8s-node01.magedu.com     <none>           <none>
```


## Storage Class Usage (Dynamic Provisioning)

 -  Create a storage class
 > change `server`, `share` with your existing NFS server address and share name
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: nfs-server.nfs.svc.cluster.local
  share: /
  # csi.storage.k8s.io/provisioner-secret is only needed for providing mountOptions in DeleteVolume
  # csi.storage.k8s.io/provisioner-secret-name: "mount-options"
  # csi.storage.k8s.io/provisioner-secret-namespace: "default"
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - nconnect=8  # only supported on linux kernel version >= 5.3
  - nfsvers=4.1
```

 - create PVC
```console
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/pvc-nfs-csi-dynamic.yaml
```

## PV/PVC Usage (Static Provisioning)

- Follow the following command to create `PersistentVolume` and `PersistentVolumeClaim` statically.

```bash
# create PV
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/pv-nfs-csi.yaml

# create PVC
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/pvc-nfs-csi-static.yaml
```

## Create a deployment
```console
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/deployment.yaml
```

