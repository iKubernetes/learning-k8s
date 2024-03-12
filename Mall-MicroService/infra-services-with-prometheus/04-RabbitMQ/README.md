# 部署Rabbit Cluster

首先，运行如下命令，创建名称空间。
```bash
kubectl create namespace rabbit
```

而后，运行如下命令，部署Rabbit Cluster。
```bash
kubectl apply -f ./ -n rabbit
```

类似如下的URL可用于访问RabbitMQ内置的管理Web UI。
http://rabbitmq.magedu.com

默认的用户名和密码是“admin/magedu.com”。

为mall-microservice提供服务时,需要创建新的用户malladmin/magedu.com,并创建新的vhost，名称为/mall，并授权给malladmin用户。


## 版权声明

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
