# 几个基础服务部署示例

### 环境依赖说明

1. 持久化存储依赖于两个存储类

   - csi-driver-nfs存储，存储类名称为“nfs-csi”；

   - openebs存储，存储类名称为“openebs-hostpath”

2. Ingress依赖于Cilium ingressclass，需要部署Cilium网络插件，并同时启用Ingress功能；

### 部署过程

请参考每个服务的单独说明。



## 版权声明

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
