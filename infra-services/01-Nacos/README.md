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

### 部署Nacos

```bash
kubectl apply -f 03-nacos-persistent.yaml  -n nacos
```

#### 登录nacos
http://nacos.magedu.com

默认用户名和密码: nacos/nacos

#### 导入数据的方法示例

```bash
curl --location --request POST 'http://nacos-0.nacos:8848/nacos/v1/cs/configs?import=true&namespace=public' \
       --form 'policy=OVERWRITE' --form 'file=@"/PATH/TO/ZIP_FILE"'
```

例如，下面的命令可以导入指定的示例文件中的配置,其中的10.244.3.41是nacos进程监听地址。
```bash
curl --location -XPOST 'http://10.244.3.41:8848/nacos/v1/cs/configs?import=true&namespace=public' \
            --form 'policy=OVERWRITE' --form 'file=@"examples/nacos_config_20230808.zip"'
```
