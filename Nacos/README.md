# 部署Nacos集群

依赖条件：
- 一个支持动态PV置备的StorageClass，本示例使用的是nfs-csi；

### 部署MySQL主从复制集群

#### 部署过程

```bash
kubectl apply -f ./ -n mall
```

#### 访问入口

读请求：mysql-read.mall.svc.cluster.local

写请求：mysql-0.mysql.mall.svc.cluster.local

### 部署Nacos

```bash
kubectl apply -f ./
```

#### 导入数据的方法示例

```bash
curl --location --request POST 'http://nacos-0.nacos:8848/nacos/v1/cs/configs?import=true&namespace=public' \
       --form 'policy=OVERWRITE' --form 'file=@"/PATH/TO/ZIP_FILE"'
```

例如，下面的命令可以导入指定的示例文件中的配置。
```bash
curl --location -XPOST 'http://10.244.3.41:8848/nacos/v1/cs/configs?import=true&namespace=public' \
            --form 'policy=OVERWRITE' --form 'file=@"examples/nacos_config_20230806.zip"'
```
