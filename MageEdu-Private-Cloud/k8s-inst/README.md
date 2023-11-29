# 部署Kubernetes集群

本文档给出两种初始化集群的方式：

- 手动创建Kubernetes集群；
- 结合OpenStack Heat模板和集群初始化脚本自动化创建Kubernetes集群；

## 手动创建Kubernetes集群

前提：

1. 为各节点确定要使用的主机名，对应修改各主机的主机名，并在各节点通过/etc/hosts文件设置其名称解析；

2. 修改配置文件kubeadm-init-config.yaml，将关于控制平面第一个节点的主机名和IP地址完成对应修改；

> 提示：如下步骤中，如果registry.magedu.com/google_containers仓库中没有可用的Image，则可以将之替换为registry.aliyuncs.com进行。
>

### 部署过程

第一步，列出Image，使用registry.magedu.com/google_containers作为Image Registry。

```bash
kubeadm config images list --image-repository=registry.magedu.com/google_containers
```

第二步，下载各Image，使用registry.magedu.com/google_containers作为Image Registry。

```bash
kubeadm config images pull --cri-socket unix:///run/cri-dockerd.sock --image-repository=registry.magedu.com/google_containers
```

第三步，基于现在的pause image生成“registry.k8s.io/pause:3.6“标签。若不想采用该步骤，还可以在kubeadm的配置文件（）中指定要使用puase image，配置方式为“KUBELET_KUBEADM_ARGS="--network-plugin=cni --pod-infra-container-image=registry.magedu.com/google_containers/pause:3.9"”。

```bash
docker image tag registry.magedu.com/google_containers/pause:3.9  registry.k8s.io/pause:3.6
```

第四步，运行脚本，生成kubeadm init的配置文件。

确认generate-init-config.sh脚本文件中各配置已经适配到当前环境，尤其是控制平面第一个节点的主机名和IP地址，以及API Server的接入端点等； 确认完成后运行脚本，即可生成配置文件kubeadm-init-config.yaml 。

```bash
bash generate-init-config.sh
```

第五步，运行如下命令，初始化控制平面的第一个节点。

```
kubeadm init --config ./kubeadm-init-config.yaml  --upload-certs
```

第六步，按上面的初始化命令输出的提示，复制Kubernetes管理员的认证配置。

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

第七步，部署网络插件，以flannel为例。

```bash
kubectl apply -f https://raw.githubusercontent.com/iKubernetes/learning-k8s/master/MageEdu-Private-Cloud/flannel/kube-flannel.yml
```

第八步，（如何需要）按kubeadm init命令输入中提示，添加控制平面的其它节点。

第九步，按kubeadm init命令输入中提示，添加工作节点至集群中；在将节点添加至集群之前，建议先运行如下命令，准备好所需要用到的pause镜像。

```bash
docker image pull registry.magedu.com/google_containers/pause:3.9
docker image tag registry.magedu.com/google_containers/pause:3.9  registry.k8s.io/pause:3.6
```

待如上两个命令运行结束后，再运行kubeadm join命令。需要提醒的是，如果使用了cri-dockerd和docker-ce作为CRI的实现，需要在kubeadm join命令上附加“--cri-socket unix:///run/cri-dockerd.sock”选项。

## 自动部署Kubernetes集群

在马哥教育的私有云实验上，该部署方式主要由两个步骤组成。

### 初始化主机环境

基于OpenStack Heat模板文件，在马哥教育的私有云上，基于“资源编排”创建“堆栈”，导入如下之一的预置模板文件，即可快速初始化出由一个Master和三个Worker组成的集群环境。

- MageEdu-Private-Cloud/openstack-heat-templates/cluster-base-env-floatingip.tmpl
- MageEdu-Private-Cloud/openstack-heat-templates/cluster-base-env.tmpl

待“堆栈”初始化完成后，它会自动创建如下的主机环境：

- 网络：192.168.10.0/24
- Master节点：192.168.10.6，主机名k8s-master01，事先安装了v1.27.3版本的kubeadm、kubectl和kubelet，以及docker和cri-dockerd；
- 三个Worker Nodes主机：
  - 分别为k8s-node01（192.168.10.11）、k8s-node02（192.168.10.12）和k8s-node03（192.168.10.13）
  - 各主机事先安装了v1.27.3版本的kubeadm、kubectl和kubelet，以及docker和cri-dockerd；

### 部署单控制平面的集群

cluster_init_script目录下的脚本文件cluster-init.sh，能够根据用户指定的Master主机地址和Worker主机地址，自动初始化出Kubernetes集群控制平面，并将各Worker主机加入到该集群中。

该脚本需要在控制平面的第一个主机上以root用户的身份运行。

```bash
bash cluster-init.sh
```



待加入的功能（即目前尚不支持的功能）：

- 安装指定版本的Kubernetes；目前默认安装的版本为v1.27.3；
- 自动添加控制平面的其它节点；
- 部署必要的各附件，例如csi-driver-nfs、ingress-nginx、metrics-server和dashboard等；
- ...

## 拆除集群

重置集群节点（危险操作，请谨慎执行）。

```bash
kubeadm reset --cri-socket unix:///run/cri-dockerd.sock
rm -rf /etc/kubernetes/ /var/lib/kubelet /var/lib/dockershim /var/run/kubernetes /var/lib/cni /etc/cni/net.d /var/lib/etcd /run/flannel/
```

