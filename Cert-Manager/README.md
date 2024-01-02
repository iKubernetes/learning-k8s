# Cert Manager

Cert-Manager是Kubernetes系统上的证书生管理工具，支持证书的申请、签发等功能，且能够在过期前自动更新证书。支持的签发者包括 Let's Encrypt (ACME),、HashiCorp Vault、Venafi TPP / TLS Protect Cloud，以本地的私有签发源，如下图所示。



![](https://camo.githubusercontent.com/a44fb472b96642d958efa8cd639a25021b9b82b17e160ffa3f7881a54c99f42f/68747470733a2f2f636572742d6d616e616765722e696f2f696d616765732f686967682d6c6576656c2d6f766572766965772e737667)

Cert-Manager会在Kubernetes集群创建专有的CRD，用户可通过创建CRD资源对象来指示Cert-Manager签发证书并为证书自动续期。 

- **Issuer/ClusterIssuer**：CRD，定义Cert-Manager要使用的证书签发者；
- **Certificate**：CRD，向Cert-Manager请求签发证书时，提交域名等证书信息、签发证书所需要的其它配置，以及要使用的Issuer/ClusterIssuer（指定由哪个签发者负责签发该证书）等；

## 部署Cert Manager

Cert Manager支持多种部署方式，下面是直接使用kubectl命令进行的静态部署。

```bash 
CM_VERSION='v1.13.3'
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CM_VERSION}/cert-manager.yaml
```

以上命令默认将Cert Manager部署于cert-manager名称空间，运行类似如下命令，可检查部署状态。

```bash 
kubectl get all --namespace cert-manager
```

确认所有的Pod对象转入“Running”状态后，即可使用相关的服务。

Cert Manager还提供了一个专用的命令行工具cmctl，运行下面的命令，即安装该工具。

```bash
CM_VERSION='v1.13.3'
curl -LO https://github.com/cert-manager/cert-manager/releases/download/${CM_VERSION}/cmctl-linux-amd64.tar.gz
tar xzf cmctl-linux-amd64.tar.gz -C /usr/local/bin
```

cmctl工具提供了多个子命令，其中的check可用于检查Cert Manager API是否就绪。

```bash 
cmctl check api
```

若上面命令打印类似“The cert-manager API is ready”的结果，则表示Cert Manager API已经就绪。

## 使用Cert Manager创建CA和证书

### 创建私有CA

首先创建一个使用自签证书的CA。

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: default
spec:
  selfSigned: {}
```

接着，为私有CA创建一个Certificate，并由使用自签证书的CA进行签署。

```yaml 
# CA Certificate
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: private-ca
spec:
  isCA: true
  commonName: private-ca
  subject:
    organizations:
      - MageEdu
    organizationalUnits:
      - DevOps
  secretName: private-ca-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-issuer
    kind: Issuer
    group: cert-manager.io
root@k8s-master01:~/cert-manager# cat cert-manager-private-ca-issuer.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: private-ca-issuer
  namespace: default
spec:
  ca:
    secretName: private-ca-secret
```

随后，即可创建使用该证书的私有CA。

```YAML 
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: private-ca-issuer
  namespace: default
spec:
  ca:
    secretName: private-ca-secret
```

### 使用Cert Manager签发证书

下面是一个服务端证书示例，创建后，由指定的private-ca-issuer这一私有CA进行签署。

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx-server
  namespace: default
spec:
  secretName: nginx-server-tls
  isCA: false
  usages:
    - server auth
    - client auth
  dnsNames:
  - "nginx-server.default.svc.cluster.local"
  - "nginx-server"
  issuerRef:
    name: private-ca-issuer
```

## 配置Cert Manager使用Kubernetes CA

本节中的配置，仅为演示如何将现有的证书和私钥配置为Cert Manger上的Issuer。

### 将Kubernetes CA创建为Cert Manager的ClusterIssuer

首先，将Kubernetes CA的证书和私钥创建成tls类型的Secret，以便于Cert Manager引用，并以为创建为CA。

```bash
kubectl create secret tls kube-root-ca --cert=/etc/kubernetes/pki/ca.crt --key=/etc/kubernetes/pki/ca.key -n cert-manager
```

创建Cluster Issuer，将Kubernetes CA配置成为Cert Manager上可用的CA。

```yaml
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: kube-root-ca-issuer
  namespace: kube-system
spec:
  ca:
    secretName: kube-root-ca
```

### 由Kubernetes CA签署证书

接下来，即可由Cert Manager上的Kubernetes CA进行证书签署测试。

```yaml 
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: apiserver-user-kubeadmin-cert
spec:
  secretName: apiserver-user-kubeadmin-tls
  privateKey:
    rotationPolicy: Always
    algorithm: RSA
    encoding: PKCS1
    size: 4096
  duration: 168h # 1 week
  renewBefore: 48h # 2 days
  subject:
    organizations:
      - system:masters
  commonName: kubeadmin
  isCA: false
  usages:
    - client auth
  issuerRef:
    name: kube-root-ca-issuer
    kind: ClusterIssuer
```

### 测试签署的证书

创建Pod，挂载保存有签署的证书相关的Secret卷，并在Pod内通过kubectl加载这些证书测试访问API Server。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-cert-secret
spec:
  containers:
  - name: kubectl
    image: bitnami/kubectl:1.28
    imagePullPolicy: IfNotPresent
    command: ["/bin/sh","-c","sleep 99999"]
    volumeMounts:
    - name: cert
      mountPath: "/certs"
      readOnly: true
  volumes:
  - name: cert
    secret:
      secretName: apiserver-user-kubeadmin-tls
```

运行如下命令，进行Pod的交互式接口，该Pod的容器使用的Image，主要用于提供kubectl命令行工具。

```bash 
kubectl exec -it pod-with-cert-secret -- /bin/bash
```

在Pod的交互式接口中即可测试该命令以挂载点下的证书和私钥是否能成功认证到API Server上。运行如下命令，查看认证的结果。

```yaml
kubectl -s https://10.96.0.1 --certificate-authority=/certs/ca.crt --client-certificate=/certs/tls.crt --client-key=/certs/tls.key auth whoami
```

