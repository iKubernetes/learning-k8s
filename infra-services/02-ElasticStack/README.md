# 部署Elasticsearch及相关组件

创建名称空间
```bash
kubectl create namespace elastic
```

部署elasticsearch

```bash
kubectl apply -f 01-elasticsearch-cluster-persistent.yaml -n elastic
```

部署filebeat

```bash
kubectl apply -f 02-filebeat.yaml -n elastic
```

部署kibana

```bash
kubectl apply -f 03-kibana.yaml -n elastic
```

通过Ingress访问Kinbana,请事先确保将kibana.magedu.com解析至ingress controller service的外部地址.
http://kibana.magedu.com
