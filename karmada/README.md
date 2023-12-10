# Karmada多集群应用编排示例

Karmada（Kubernetes Armada）是跨Kubernetes集群的应用程序编排系统，旨在帮助用户在多个Kubernetes集群和云中运行云原生应用程序，而无需更改应用程序。通过使用Kubernetes原生API并提供先进的调度功能，Karmada实现了真正的开放式、多云Kubernetes。

### 应用分发测试

创建用于测试的应用demoapp。

```bash
kubectl apply -f 01-demoapp-deployment.yaml \
    --kubeconfig=/etc/karmada/karmada-apiserver.config
```



创建用于测试应用分发功能的Propagation Policy。

```bash
kubectl apply -f 02-demoapp-propergation-policy.yaml \
    --kubeconfig=/etc/karmada/karmada-apiserver.config
```



### 差异化策略测试

继前一个步骤后，创建Override Policy，进行差异化测试。

```bash 
kubectl apply -f 03-demoapp-override-policy.yaml \
    --kubeconfig=/etc/karmada/karmada-apiserver.config
```



### 高可用部署

基于Duplicated模式，跨多个Region或Cluster部署应用程序的多个复制副本，即可实现应用的高可用部署。

```bash 
kubectl apply -f 04-propagationpolicy-ha.yaml \
    --kubeconfig=/etc/karmada/karmada-apiserver.config
```



### 分散式部署

基于Divided模式，跨多个Region或Cluster部署应用程序的多个分割副本，即可实现应用的跨集群分布式部署。

```bash 
kubectl apply -f 05-propagationpolicy-spread.yaml \
    --kubeconfig=/etc/karmada/karmada-apiserver.config
```



### 故障转移

某个成员集群故障时，Karmada可将应用的副本迁移至其它成员集群之上。

```bash 
kubectl apply -f 06-propagationpolicy-failover.yaml \
    --kubeconfig=/etc/karmada/karmada-apiserver.config
```



## 版权声明

本项目由[马哥教育](www.magedu.com)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。欢迎扫描下面的二维码关注iKubernetes公众号，及时获取更多技术文章。

![ikubernetes公众号二维码](https://github.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/raw/main/imgs/iKubernetes%E5%85%AC%E4%BC%97%E5%8F%B7%E4%BA%8C%E7%BB%B4%E7%A0%81.jpg)
