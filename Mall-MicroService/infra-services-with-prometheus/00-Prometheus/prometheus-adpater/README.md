部署Prometheus Adapater
==================

1. Prometheus Adapater的v0.8.4及之后版本的Image仅能通过 “registry.k8s.io/prometheus-adapter/prometheus-adapter:$VERSION”获取，之前版本的镜像，可到“quay.io/repository/coreos/k8s-prometheus-adapter-amd64” 仓库上查找。本示例中部署的是v0.10.0的版本。

2. 创建名为custom-metrics的名称空间。

   ```bash
   kubectl create namespace custom-metrics
   ```

3. 创建一个名为cm-adapter-serving-certs的secret对象，它需要具备serving.crt和serving.key两个键。These are the serving certificates used
   by the adapter for serving HTTPS traffic，更多的信息，请参考[auth concepts documentation](https://github.com/kubernetes-incubator/apiserver-builder/blob/master/docs/concepts/auth.md)。我们也可通过如下命令，运行目录中预置的gencerts.sh脚本进行创建。

   ```bash
   bash gencerts.sh
   ```

   该脚本会在manifests目录下创建一个cm-adapter-serving-certs.yaml的文件，它提供了相关secret对象的配置。另外，该脚本依赖于golang的cfssl模块，下面的命令也能在Ubuntu Server完成该模块的安装。

   ```bash
   apt-get install -y golang-cfssl
   ```
   
4. 运行如下命令，在custom-metrics名称空间中部署prometheus-adapter。

   ```bash
   kubectl apply -f manifests/
   ```

   > 提示：
   >
   > - 在部署prometheus-adpater之前，你可能需要事先修改ConfigMap资源，以添加需要暴露的自定义指标，例如这个[示例](example-metrics/custom-metrics-config-map.yaml)中最后一条规则的定义所示。
   > - 该部署示例中的prometheus-adapter会向prom名称空间中prometheus service（prometheus.prom.svc.cluster.local）发起查询请求，请确保prometheus service的访问路径指向了正确的位置。

5. 运行下面命令，部署示例应用。该示例应用提供了一个Counter类型的指标http_requests_total。

   ```bash
   kubectl apply -f example-metrics/metrics-example-app.yaml
   ```

6. 运行如下命令，将metrics-app示例应用中暴露的指标http_requests_total转为速率指标，并提供给Kubernetes的自定义指标管道使用。

   ```bash
   kubectl apply -f example-metrics/custom-metrics-config-map.yaml
   ```

   确认配置被重新加载后，即可使用相关的指标。例如下面的命令，通过Kubernetes的custom.metrics API获取到了metrics-app的两个Pod上的指标数据。

   ```bash
   kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second | jq .
   {
     "kind": "MetricValueList",
     "apiVersion": "custom.metrics.k8s.io/v1beta1",
     "metadata": {},
     "items": [
       {
         "describedObject": {
           "kind": "Pod",
           "namespace": "default",
           "name": "metrics-app-6bbb4f6774-kjfr6",
           "apiVersion": "/v1"
         },
         "metricName": "http_requests_per_second",
         "timestamp": "2023-05-25T07:13:04Z",
         "value": "4300m",
         "selector": null
       },
       {
         ...
       }
     ]
   }
   ```

7. 该指标可用于使用HPAv2控制器来自动伸缩前面部署的metrics-app，这里提供了一个[示例](example-metrics/metrics-app-hpa.yaml)，部署后即可进行测试。
