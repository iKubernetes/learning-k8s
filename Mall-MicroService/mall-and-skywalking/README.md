# mall microservice项目相关的部署文件

本示例中，各service的配置中均启用了skywalking java agent，它们会将链路跟踪相关的数据发送至指定的Skywalking OAP服务中。

### 依赖的基础环境

本示例中的mall microservice依赖于MySQL、Nacos、Redis、MongoDB、RabbitMQ、ElasticSearch（需要部署中文分词插件）和MinIO等相关的服务。

具体的过程，请参考infra-services或infra-services-with-prometheus目录中的部署方法。

### 部署方法

创建名称空间，用以部署各服务。

```bash
kubectl create namespace mall
```

运行如下命令，部署各服务。

```bash
kubectl apply -f ./ -n mall
```





## 版权声明

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
