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

默认的用户名和密码是“guest/guest”。安全起见，建议修改用户的密码，或者创建其它管理员账号后禁用该用户。

为mall-microservice提供服务时,需要创建新的用户malladmin/magedu.com,并创建新的vhost，名称为/mall，并授权给malladmin用户。



### 版权声明

本示例由[马哥教育](http://www.magedu.com)原创，允许自由转载，商用必须经由马哥教育的书面同意。
