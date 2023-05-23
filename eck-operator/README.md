
# eck-operator

eck-operator是Elastic官方维护的Elastic Stack相关各组件的Operator。

部署文档页面在[这里](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html)。

## 部署ElasticSearch

提示：部署ElasticSearch的过程依赖于一个可用的默认StorageClass，或者在配置中明确指定要使用的StorageClass。

下面的配置清单定义了一个ElasticSearch集群，版本为8.7.1。

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: myes
spec:
  version: 8.7.1
  nodeSets:
  - name: default
    count: 3
    config:
      node.store.allow_mmap: false
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 20Gi
        storageClassName: nfs-csi
```

访问ElasticSearch，要通过其名字中以集群名称为前缀（例如myes），以“-es-http”后缀的Service进行，例如下面命令结果中的servcies/myes-es-http。

\~$ kubectl get svc -n elastic-system
NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
elastic-operator-webhook   ClusterIP   10.101.161.55    <none>        443/TCP    23m
myes-es-default            ClusterIP   None             <none>        9200/TCP   14m
myes-es-http               ClusterIP   10.110.174.153   <none>        9200/TCP   14m
myes-es-internal-http      ClusterIP   10.106.192.197   <none>        9200/TCP   14m
myes-es-transport          ClusterIP   None             <none>        9300/TCP   14m


我们还要事先获取到访问ElasticSearch的密码，该密码由部署过程自动生成，并保存在了相关名称空间下的Secrets中，该Secrets对象以集群名称为前缀，以“-es-elastic-user”为后缀。下面的命令将获取到的密码保存在名为PASSWORD的变量中。

\~$ PASSWORD=$(kubectl get secret myes-es-elastic-user -n elastic-system -o go-template='{{.data.elastic | base64decode}}')


随后，我们即可在集群上通过类似如下命令访问部署好的ElasticSearch集群。

\~$ kubectl run client-$RANDOM --image ikubernetes/admin-box:v1.2 -it --rm --restart=Never --command -- /bin/bash

\~# curl -u "elastic:$PASSWORD" -k https://myes-es-http.elastic-system:9200
{
  "name" : "myes-es-default-1",
  "cluster_name" : "myes",
  "cluster_uuid" : "Dv-m6dyNSumIebUkQV6u4g",
  "version" : {
    "number" : "8.7.1",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "f229ed3f893a515d590d0f39b05f68913e2d9b53",
    "build_date" : "2023-04-27T04:33:42.127815583Z",
    "build_snapshot" : false,
    "lucene_version" : "9.5.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}


## 部署Filebeat

下面的配置清单定义了一个Beats资源，它以DaemonSet控制器在每个节点上运行一个filebeat实例，收集日志并保存至ElasticSeach集群中。应用的版本同样为8.7.1。

```yaml
apiVersion: beat.k8s.elastic.co/v1beta1
kind: Beat
metadata:
  name: filebeat
  namespace: elastic-system
spec:
  type: filebeat
  version: 8.7.1
  elasticsearchRef:
    name: "myes"
  kibanaRef:
    name: "kibana"
  config:
    filebeat:
      autodiscover:
        providers:
        - type: kubernetes
          node: ${NODE_NAME}
          hints:
            enabled: true
            default_config:
              type: container
              paths:
              - /var/log/containers/*${data.kubernetes.container.id}.log
        processors:
        - add_kubernetes_metadata:
            host: ${NODE_NAME}
            matchers:
            - logs_path:
                logs_path: "/var/log/containers/"
        - drop_event.when:
            or:
            - equals:
                kubernetes.namespace: "kube-system"
            - equals:
                kubernetes.namespace: "monitoring"  
            - equals:
                kubernetes.namespace: "ingress-nginx"
            - equals:
                kubernetes.namespace: "kube-node-lease"
            - equals:
                kubernetes.namespace: "elastic-system"
  daemonSet:
    podTemplate:
      spec:
        serviceAccountName: filebeat
        automountServiceAccountToken: true
        terminationGracePeriodSeconds: 30
        dnsPolicy: ClusterFirstWithHostNet
        hostNetwork: true # Allows to provide richer host metadata
        containers:
        - name: filebeat
          securityContext:
            runAsUser: 0
            # If using Red Hat OpenShift uncomment this:
            #privileged: true
          volumeMounts:
          - name: varlogcontainers
            mountPath: /var/log/containers
          - name: varlogpods
            mountPath: /var/log/pods
          - name: varlibdockercontainers
            mountPath: /var/lib/docker/containers
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
        volumes:
        - name: varlogcontainers
          hostPath:
            path: /var/log/containers
        - name: varlogpods
          hostPath:
            path: /var/log/pods
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: filebeat
rules:
- apiGroups: [""] # "" indicates the core API group
  resources:
  - namespaces
  - pods
  - nodes
  verbs:
  - get
  - watch
  - list
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: filebeat
  namespace: elastic-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: filebeat
subjects:
- kind: ServiceAccount
  name: filebeat
  namespace: elastic-system
roleRef:
  kind: ClusterRole
  name: filebeat
  apiGroup: rbac.authorization.k8s.io
---
```

待所有Pod就绪、收集日志并发往ElasticSearch之后，在ElasticSearch上即能生成相关的索引。

\~# curl -u "elastic:$PASSWORD" -k https://myes-es-http.elastic-system:9200/_cat/indices
green open .fleet-files-agent-000001            6PfhLWE-Rvu8sheE7-nFqw 1 1     0 0   450b   225b
green open .ds-filebeat-8.7.1-2023.05.23-000001 kLZmXupSRqmJUKzlp8ETCQ 1 1 22549 0 24.4mb 12.3mb
green open .fleet-file-data-agent-000001        oxPnPWV2T6K5Jpq6IFNFFw 1 1     0 0   450b   225b


## 部署Kibana

下面的配置清单定义了一个Kibana资源，它会创建一个Kibana实例，并关联至前面创建的ElasticSeach集群myes中。应用的版本同样为8.7.1。


```yaml
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: kibana
  namespace: elastic-system
spec:
  version: 8.7.1
  count: 1
  elasticsearchRef:
    name: "myes"
  http:
    tls:
      selfSignedCertificate:
        disabled: true
  #http:
  #  service:
  #    spec:
  #      type: LoadBalancer
  # this shows how to customize the Kibana pod
  # with labels and resource limits
  podTemplate:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        resources:
          limits:
            memory: 1Gi
            cpu: 1
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kibana
  namespace: elastic-system
spec:
  ingressClassName: nginx
  rules:
  - host: kibana.magedu.com
    http:
      paths:
      - backend:
          service:
            name: kibana-kb-http
            port:
              number: 5601
        path: /
        pathType: Prefix
  # tls:
  # - hosts:
  #   - host-name
  #   secretName: tls-secret-name
```

待相关的Pod就绪后，使用ElasticSearch部署时生成的用户elastic及其密码即可登录。密码获取命令如下。

\~$ PASSWORD=$(kubectl get secret myes-es-elastic-user -n elastic-system -o go-template='{{.data.elastic | base64decode}}')


