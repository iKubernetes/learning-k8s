
# Kube-Promethes

部署Prometheus及其相关的各组件是一项复杂的任务，好在，Prometheus Operator项目能够在Kubernetes环境上简化和自动化该过程。

> Operator建立在Kubernetes的两个关键原则之上：自定义资源 (CR)，它通过自定义资源定义 (CRD) 和自定义的Controller实现。



Kube-Prometheus Opertor的主要目的，是用于简化和自动化管理在Kubernetes集群上运行的Prometheus监控套件。本质上，它是一个自定义控制器，用于监视通过以下CRD引入的资源类型下的对象。

- **Prometheus**：编排运行Prometheus Server实例
- **Alertmanager**：编排运行Alertmanager实例
- **ServiceMonitor**：定义要监视Kubernetes Service资源对象
- **PodMonitor**：定义要监视的Pod资源对象
- **Probe**：定义要监控的Ingess或静态Target，黑盒监控模式
- **PrometheusRule**：为Prometheus Server定义告警规划或记录规则
- **AlertmanagerConfig**：以声明方式为Alertmanager提供配置段
- **PrometheusAgent**：编排运行Prometheus Agent
- **scrapeconfigs**：为Prometheus Server提供scrape_config相关的配置段
- thanosrulers：

