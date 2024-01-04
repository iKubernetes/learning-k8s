# 创建CSR并签署证书

本示例用于演示创建CertificateSingRequest资源，并进行签署。

### 创建数字证书

首先，创建证书签署请求。

```bash
mkdir certs && cd certs/
openssl genrsa -out mason.key 2048
openssl req -new -key myuser.key -out mason.csr -subj "/CN=mason/O=developers"
```

#### 创建证书（方式一）

而后，创建CertificateSignRequest资源配置文件。

```bash
cat > certificatesignrequest-mason.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: mason
spec:
  # request字段的值，是csr文件内容经base64编码后的结果
  # 用于生成编码的命令：cat mason.csr | base64 | tr -d "\n"
  request: $(cat mason.csr | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 864000  # ten days
  usages:
  - client auth
EOF
```

接下来，将资源配置提交至Kubernetes。

```bash
kubectl apply -f certificatesignrequest-mason.yaml
kubectl get csr
```

下一步，进行证书签署。

```bash 
kubectl certificate approve mason
```

最后，获取并保存证书文件。

```bash
kubectl get csr mason -o jsonpath='{.status.certificate}'| base64 -d > mason.crt 
```

#### 创建证书（方式二）

也可以运行命令，直接基于Kubernetes CA签署并生成证书文件。

```bash
openssl x509 -req -days 10 -CA /etc/kubernetes/pki/ca.crt  -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial  -in ./mason.csr -out ./mason.crt
```

### 测试证书认证

将mason.crt、mason.key和ca.crt复制到某部署了kubectl的主机上，即可进行测试，这里以k8s-node01为示例。
```bash
kubectl get pods --client-certificate=./mason.crt --client-key=./mason.key --server=https://kubeapi.magedu.com:6443/ --certificate-authority=./ca.crt
```

也可以使用直接curl命令进行请求测试。

```bash
curl --cert ./mason.crt --key ./mason.key --cacert ./ca.crt  https://kubeapi.magedu.com:6443/api/v1/namespaces/default/pods
```

## 版权声明

本文档由[马哥教育](http://www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。
