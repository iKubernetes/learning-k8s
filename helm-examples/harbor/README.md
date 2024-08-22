# Helm 部署 Harbor

首先，运行如下命令，添加harbor的Chart仓库。

```bash
helm repo add harbor https://helm.goharbor.io
```

而后，运行如下命令，基于该仓库中的值文件“harbor-values.yaml”即可部署Harbor。它默认依赖于“nfs-csi”存储类。

```bash
helm install harbor -f harbor-values.yaml harbor/harbor -n harbor --create-namespace
```

若需要基于“openebs-hostpath”存储类进行部署，则可以改用如下命令进行部署。

```bash
helm install harbor -f harbor-values-openebs.yaml harbor/harbor -n harbor --create-namespace
```

### 版权声明

本示例由[马哥教育](http://www.magedu.com)原创，允许自由转载，商用必须经由马哥教育的书面同意。
