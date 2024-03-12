# 微服务商城

教学案例，用于部署如下系统：

- 部署Kubernetes集群及基础组件；
- 部署微服务商城依赖的各类后端服务，相关配置文件及部署说明位于目录“infra-services-with-prometheus”目录中；
  - 00-Prometheus：Prometheus监控组件，及自定义指标流水线的相关部署配置；
  - 01-Nacos：MySQL和Nacos；
  - 02-ElasticStack：ElasticSearch、Fluent-Bit和Kibana；
  - 03-Redis：Redis Master/Slave Cluster;
  - 04-RabbitMQ：RabbitMQ Cluster；
  - 05-MongoDB：MongoDB ReplicaSet Cluster；
  - 06-MinIO：MinIO Cluster;
  - 07-SkyWaling：SkyWalking和SkyWalking UI；
- 部署微服务商城，相关配置文件位于目录“mall-and-skywalking”目录中；
- 部署微服务商城商家端的Web UI，相关配置文件位于目录“mall-and-skywalking”目录中；

### 依赖到的环境

该示例提供的配置文件，依赖于满足如下条件的Kubernetes集群：

- 部署有Cilium网络插件，启用了Cilium Ingress；
- 部署有MetalLB，支持LoadBalancer Service；
- 部署有OpenEBS，提供了openebs-hostpath存储类；
- （可选）部署有csi-driver-nfs和一个可用的NFS Server，提供了nfs-csi存储类；
- （可选）部署有Metrics Server；

