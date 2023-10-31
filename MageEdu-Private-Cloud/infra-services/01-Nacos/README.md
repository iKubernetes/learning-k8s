# 部署Nacos集群

依赖条件：
- 一个支持动态PV置备的StorageClass，本示例使用的是nfs-csi；

### 部署MySQL主从复制集群

#### 部署过程

创建名称空间
```bash
kubectl create namespace nacos
```

```bash
kubectl apply -f 01-secrets-mysql.yaml -f  02-mysql-persistent.yaml -n nacos
```

#### 访问入口

读请求：mysql-read.mall.svc.cluster.local

写请求：mysql-0.mysql.mall.svc.cluster.local

#### 创建用户账号
在mysql上创建nacos专用的用户账号，本示例中，Naocs默认使用nacos用户名和"magedu.com"密码访问mysql服务上的nacosdb数据库。

```bash
kubectl exec -it mysql-0 -n nacos -- mysql -uroot -hlocalhost
在mysql的提示符下运行如下SQL语句后退出即可
mysql> GRANT ALL ON nacosdb.* TO nacos@'%' IDENTIFIED BY 'magedu.com';
```

### 部署Nacos

```bash
kubectl apply -f 03-nacos-persistent.yaml  -n nacos
```

#### 登录nacos
若部署了Ingress Controller，并将nacos.magedu.com名称解析至Ingress Controller相关Service的External IP，然后通过如下地址进行访问。
http://nacos.magedu.com/nacos

本配置示例中，默认没有开启鉴权机制。 

若需要基于LoadBalancer Service访问，则在nacos名称空间中创建如下配置定义的资源后，即可使用获取的loadbalancer ip进行访问。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nacos
  labels:
    app: nacos
spec:
  type: LoadBalancer
  ports:
    - port: 8848
      name: server
      targetPort: 8848
  selector:
    app: nacos
```

通过service/nacos的loadbalancer ip的8848端口即可发起访问请求
http://loadbalancer_ip:8848/nacos

#### 导入数据的方法示例

```bash
curl --location --request POST 'http://nacos-0.nacos:8848/nacos/v1/cs/configs?import=true&namespace=public' \
       --form 'policy=OVERWRITE' --form 'file=@"/PATH/TO/ZIP_FILE"'
```

例如，下面的命令可以导入指定的示例文件中的配置,其中的10.244.3.41是nacos进程监听地址。
```bash
curl --location -XPOST 'http://10.244.3.41:8848/nacos/v1/cs/configs?import=true&namespace=public' \
            --form 'policy=OVERWRITE' --form 'file=@"examples/nacos_config_20231029.zip"'
```
