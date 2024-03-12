# 部署Elasticsearch及相关组件

创建名称空间
```bash
kubectl create namespace elastic
```

部署elasticsearch

```bash
kubectl apply -f 01-elasticsearch-cluster-persistent.yaml -n elastic
```

待ES的相关Pod就绪后，即可部署fluentd

```bash
kubectl apply -f 02-fluentbit.yaml -n elastic
```

部署kibana

```bash
kubectl apply -f 03-kibana.yaml -n elastic
```

若要通过Ingress访问Kibana,请事先确保将kibana.magedu.com解析至ingress controller service的外部地址。
http://kibana.magedu.com

若要通过LoadBalancer Service访问Kibana，请事先确保有支持LoadBalancer Service的基础环境，而后修改service/kibana的spec.type字段的值为“LoadBalancer”，而后运行如下命令了解其获得的external IP地址。

```bash
kubectl get service kibana -n elastic
```



## 版权声明

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
