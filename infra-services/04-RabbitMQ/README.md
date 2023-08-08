# 部署Rabbit Cluster

创建名称空间
```bash
kubectl create namespace rabbit
```

部署Rabbit Cluster
```bash
kubectl apply -f ./ -n rabbit
```

访问RabbitMQ内置的管理Web UI
http://rabbitmq.magedu.com

默认的用户名和密码: guest/guest

为mall-swarm提供服务时,需要创建新的用户malladmin/magedu.com,并创建新的vhost /mall,并授权给该用户.

