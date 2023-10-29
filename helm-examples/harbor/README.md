# Helm 部署 Harbor

首先，运行如下命令，添加harbor的Chart仓库。

```bash
helm repo add harbor https://helm.goharbor.io
```

而后，创建用于部署Harbor的名称空间，例如harbor。

```bash
kubeclt create namespace harbor
```

最后，运行如下命令，基于该仓库中的值文件“harbor-values.yaml”即可部署Harbor。

```bash
helm install harbor -f harbor-values.yaml harbor/harbor -n harbor
```



### 版权声明

本示例由[马哥教育](http://www.magedu.com)原创，允许自由转载，商用必须经由马哥教育的书面同意。
