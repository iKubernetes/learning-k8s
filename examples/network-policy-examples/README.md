# NetworkPolicy

测试方法NetworkPolicy的生效机制。

首先基于配置文件example-base-env.yaml中定义的资源创建用于测试的基础环境：

- namespace: dev, demo
- deployment: dev/demoapp, demo/demoapp, demo/sleep
- 服务端deployment: default/demoapp，监听80和8080两个端口；

而后，基于配置文件allow-selected-ingress-traffic.yaml中定义的资源，创建NetworkPolicy对象，生成控制规则。

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-selected-ingresses
  namespace: default
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchExpressions:
        - key: kubernetes.io/metadata.name
          operator: In
          values: ["default", "kube-system", "monitor"]
    - ipBlock:
        cidr: 192.168.10.0/24
    ports: []
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: demo
      podSelector:
        matchExpressions:
        - key: app
          operator: In
          values: ["demoapp", "nginx"]
    ports:
    - port: 80
      protocol: TCP
  policyTypes:
  - Ingress
```

