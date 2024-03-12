# Prometheus Monitoring System

- prometheus-server：部署Promethues Metrics API Server所需要的各资源配置清单。
- prometheus-adapter：部署基于prometheus的自定义指标API服务器所需要的各资源配置清单。
- podinfo：测试使用的podinfo相关的deployment和service对象的资源配置清单。
- node_exporter：于kubernetes集群各节点部署node_exporter。
- kube-state-metrics：聚合kubernetes资源对象，提供指标数据。
- alertmanager：部署AlertManager告警系统。
- grafana：部署Grafana Dashboard。

### 部署Prometheus

部署Prometheus监控系统

```bash
kubectl apply -f namespace.yaml
kubectl apply -f prometheus-server/ -n prom
```

部署node-exporter

```bash
kubectl apply -f node-exporter/
```

### 部署Kube-State-Metrics

部署kube-state-metrics，监控Kubernetes集群的服务指标。

```bash
kubectl apply -f kube-state-metrics/
```

### 部署AlertManager

部署AlertManager，为Prometheus-Server提供可用的告警发送服务。

```bash
kubectl apply -f alertmanager/
```

### 部署Prometheus Adpater

参考相关目录中的[README](prometheus-adpater/README.md)文件中的部署说明。




## 版权声明
本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)

