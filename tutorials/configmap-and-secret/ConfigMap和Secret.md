# 使用ConfigMap和Secret配置应用

版权声明：该文档由[马哥教育](http://www.magedu.com)原创，未经书面允许，严禁转载，严禁一切形式的商业用途。

## 实验介绍

ConfigMap和Secret是Kubernetes系统上两种特殊类型的存储卷，前者用于为容器中的应用提供配置数据以定制程序的行为，而敏感的配置信息，例如密钥、证书等则通常由后者来配置。在本实验场景中，我们会带你学习使用Pod支持的多种类型的存储卷，这包括：

- 命令行创建ConfigMap
- 命令行加载文件创建ConfigMap
- 通过环境变量引用ConfigMap键值
- 基于存储卷接口使用ConfigMap
- Secret资源
- 基于存储卷接口使用Secret

ConfigMap和Secret将相应的配置信息保存于资源对象中，而后在Pod对象上以存储卷的形式将其挂载并加载相关的配置，降低了配置与镜像文件的耦合关系。

ConfigMap用于在运行时将配置文件、命令行参数、环境变量、端口号以及其他配置工件绑定至Pod的容器和系统组件。Kubernetes借助于ConfigMap对象实现了将配置文件从容器镜像中解耦，从而增强了工作负载的可移植性，使其配置更易于更改和管理，并防止将配置数据硬编码到Pod配置清单中。

## Step1: 命令式参数创建ConfigMap

ConfigMap是Kubernetes标准的API资源类型，它隶属名称空间级别，支持命令式命令、命令式对象配置及声明式对象配置三种管理接口。命令式命令的创建操作可通过kubectl create configmap进行，它支持基于目录、文件或字面量值（literal）获取配置数据完成ConfigMap对象的创建。

为kubectl create configmap命令使用--from-literal选项可在命令行直接给出键值对来创建ConfigMap对象，重复使用此选项则可以一次传递多个键值对。命令格式如下：

```console
kubectl create configmap configmap_name --from-literal=key-1=value-1 …
```

例如，下面的命令创建demoapp-config时传递了两个键值对，一个是demoapp.host=0.0.0.0，一个是demoapp.port=8080。

```bash
kubectl create configmap demoapp-config --from-literal=demoapp.host='0.0.0.0' --from-literal=demoapp.port='8080'
```

从下面的get configmap命令中输出demoapp-config对象yaml格式信息可以看出，ConfigMap资源没有spec和status字段，而是直接使用data字段嵌套键值数据。

```bash
kubectl get configmaps demoapp-config -o yaml
```

```console
apiVersion: v1
data:
  demoapp.host: 0.0.0.0
  demoapp.port: "8080"
kind: ConfigMap
metadata:
  creationTimestamp: "2021-04-06T02:37:51Z"
  managedFields:
  ……
  name: demoapp-config
  ……  

```


## Step2: 命令行加载文件创建ConfigMap

ConfigMap资源也可用于为应用程序提供大段配置，这些大段配置通常保存于一到多个文本编码的文件中，可由kubectl create configmap命令通过--from-file选项一次加载一个配置文件的内容为指定的键的值，多个文件的加载可重复使用--from-file选项完成，如下面的命令所示。

```bash
 kubectl create configmap nginx-confs --from-file=./nginx-conf.d/myserver.conf --from-file=status.cfg=./nginx-conf.d/myserver-status.cfg 
```

我们可以从nginx-confs对象的配置清单来了解各键名及其相应的键值。

```bash
kubectl get configmap nginx-confs -o yaml
```

```console
apiVersion: v1
data:
  status.cfg: |       # “|”是键名及多行键值的分割符，多行键值要进行固定缩进
    location /nginx-status {       # 该缩进范围内的文本块即为多行键值
        stub_status on;
        access_log off;
    }
  myserver.conf: |
    server {
        listen 8080;
        server_name www.ik8s.io;

        include /etc/nginx/conf.d/myserver-*.cfg;

        location / {
            root /usr/share/nginx/html;
        }
    }
kind: ConfigMap
……
```

对于配置文件较多且又无需自定义键名称的场景，可以直接在kubectl create configmap命令的--from-file选项上附加一个目录路径就能将该目录下的所有文件创建于同一ConfigMap资源中，各文件的基名为即为键名。

```bash
kubectl create configmap nginx-config-files --from-file=./nginx-conf.d/
```

随后，我们获取configmap/nginx-config-files对象的完整资源清单。

```bash
kubectl get configmap/nginx-config-files -o yaml
```

类似下面的输出结果中可以看出，各文件被创建成了一个独立的键值数据，键名即为文件的基名。

```console
apiVersion: v1
data:
  myserver-gzip.cfg: |   # 键值数据一；
    gzip on;
    gzip_comp_level 5;
    gzip_proxied     expired no-cache no-store private auth;
    gzip_types text/plain text/css application/xml text/javascript;
  myserver-status.cfg: |     # 键值数据二；
    location /nginx-status {
        stub_status on;
        access_log off;
    }
  myserver.conf: |     # 键值数据三；
    server {
        listen 8080;
        server_name www.ik8s.io;

        include /etc/nginx/conf.d/myserver-*.cfg;

        location / {
            root /usr/share/nginx/html;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2021-04-06T02:38:54Z"
  managedFields:
  ......
  name: nginx-config-files
  ......
```

## Step3: 通过环境变量引用ConfigMap键值

Pod资源配置清单中，除了使用value字段直接给定变量值之外，容器环境变量的赋值还支持通过在valueFrom字段中嵌套configMapKeyRef来引用ConfigMap对象的键值。

下面示例中定义了两个资源，彼此间使用“---”相分隔。第一个资源是名为demoapp-config的ConfigMap对象，它包含了两个键值数据；第二个资源是名为configmaps-env-demo的Pod对象，它在环境变量PORT和HOST中分别引用了demoapp-config对象中的demoapp.port和demoapp.host的键的值。

```yaml
# Created-By:"MageEdu <mage@magedu.com>"
apiVersion: v1
kind: ConfigMap
metadata:
  name: demoapp-config
data:
  demoapp.port: "8080"
  demoapp.host: 0.0.0.0
---
# Created-By:"MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: configmaps-env-demo
spec:
  containers:
  - image: ikubernetes/demoapp:v1.0
    name: demoapp
    env:
    - name: PORT
      valueFrom:
        configMapKeyRef:
          name: demoapp-config
          key: demoapp.port
          optional: false
    - name: HOST
      valueFrom:
        configMapKeyRef:
          name: demoapp-config
          key: demoapp.host
          optional: true
```

运行如下命令，创建Pod对象configmaps-env-demo。

```bash
kubectl apply -f configmaps-env-demo.yaml
```

而后，验证configmaps-env-demo中的应用是否监听于由configmaps/demoapp-config资源定义的IP地址和端口上。

```bash
kubectl exec configmaps-env-demo -- netstat -tnl 
```

若输出的内容如下所示，则表示它监听于非默认（80）的8080端口上。

```console
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address      Foreign Address         State       
tcp        0      0 0.0.0.0:8080        0.0.0.0:*             LISTEN  
```

## Step4：ConfigMap存储卷

基于configMap卷插件关联至Pod资源上的ConfigMap对象可由内部的容器挂载为一个目录，该ConfigMap对象的每个键名将转为容器挂载点路径下的一个文件名，键值则映射为相应文件的内容。显然，挂载点路径应该以容器加载配置文件的目录为其名称，每个键名也应该有意设计为对应容器应用加载的配置文件名称。

```yaml
# Created-By:"MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: configmaps-volume-demo
spec:
  containers:
  - image: nginx:alpine
    name: nginx-server
    volumeMounts:
    - name: ngxconfs
      mountPath: /etc/nginx/conf.d/
      readOnly: true
      volumes:
  - name: ngxconfs
    configMap:
      name: nginx-config-files
      optional: false
```

运行如下命令，创建Pod对象configmaps-volume-demo。

```bash
kubectl apply -f configmaps-volume-demo.yaml
```

待该此Pod资源进入Running状态后，于kubernetes集群中的某客户端直接向pod IP的8080端口发起访问请求，即可验正由nginx-config-files资源提供的配置信息是否生效，例如通过/nginx-status访问其内建的stub status。

我们可以使用如下命令，完成测试。

```bash
podIP=$(kubectl get pods configmaps-volume-demo -o go-template={{.status.podIP}})
```

```bash
kubectl run pod-$RANDOM --image="ikubernetes/admin-box:v1.1" --restart=Never --env="podIP=${podIP}" --rm -it --command -- /bin/sh
```

```bash
curl http://${podIP}:8080/nginx-status
```

注意：在进行后续的步骤前，<tutorial-terminal-open-tab index="0">点击此处回到此前的tab</tutorial-terminal-open-tab>。

当然，我们也可以直接于Pod资源configmaps-volume-demo之上的相应容器中执行命令来确认文件是否存在于挂载点目录中。

```bash
kubectl exec configmaps-volume-demo -- ls /etc/nginx/conf.d
```

若命令结果中显示出myserver.conf、myserver-gzip.cfg和myserver-status.cfg文件，即表示挂载成功。

## Step5: Secret资源

Secret对象存储数据的机制及使用方式都类似于ConfigMap对象，它们以键值方式存储数据，在Pod资源中通过环境变量或存储卷进行数据访问。不同的地方在于，Secret对象仅会被分发至调用了该对象的Pod资源所在的工作节点，且仅支持由节点将其临时存储于内存中。另外，Secret对象的数据的存储及打印格式为Base64编码的字符串而非明文字符，用户在创建Secret对象时需要事先手动完成数据的格式转换。

根据其存储格式及用途的不同，Secret对象会划分为如下三种大的类别。
- generic：基于本地文件、目录或字面量值创建的Secret，一般用来存储密码、密钥、信息、证书等数据；
- docker-registry：专用于认证到Docker Registry的Secret，以使用私有容器镜像；
- tls：基于指定的公钥/私钥对创建TLS Secret，专用于TLS通信中；指定公钥和私钥必须事先存在，公钥证书必须采用PEM编码，且应该与指定的私钥相匹配；

另外，kubectl create secret genric命令，还支持使用--type选项指定secret资源对象的子类型。

下面的命令，以root/iLinux分别为用户名和密码创建了一个名为mysql-root-authn的Secret对象：

```bash
kubectl create secret generic mysql-root-authn --from-literal=username=root --from-literal=password=MagEdu.c0m
```

如下命令可获取secrets/mysql-root-authn的详细资源规范，该规范也是用户基于配置清单创建Secret资源的要使用格式。

```bash
kubectl get secrets/mysql-root-authn -o yaml
```

未指定子类型时，以generic子命令创建的Secret对象是为Opaque类型，其键值数据会以Base64的编码格式保存和打印。

```console
apiVersion: v1
data:
  password: TWFnRWR1LmMwbQ==
  username: cm9vdA==
kind: Secret
metadata:
  name: mysql-root-authn
  namespace: default
  ……
type: Opaque
```

创建用于为TLS通信场景提供专用数字证书和私钥信息的Secret对象有其专用的TLS子命令，以及专用的选项--cert和--key。出于测试的目的，我们首先使用类似如下命令生成私钥和自签证书。

```bash
openssl rand -writerand $HOME/.rnd
(umask 077; openssl genrsa -out nginx.key 2048)
openssl req -new -x509 -key nginx.key -out nginx.crt -subj /C=CN/ST=Beijing/L=Beijing/O=DevOps/CN=www.magedu.com
```

而后即可使用如下命令将这两个文件创建为secret对象。需要注意的是，无论用户提供的证书和私钥文件使用什么名称，它们一律会被转换为分别以tls.key（私钥）和tls.crt（证书）为其键名。

```bash
kubectl create secret tls nginx-ssl-secret --key=./nginx.key --cert=./nginx.crt
```

docker-registry类型的Secret主要用于让kubelet认证到私有的docker镜像仓库Registry上，以下载到相应的镜像。相应的创建命令如下所示。

```bash
kubectl create secret docker-registry local-registry --docker-username=Ops --docker-password=Opspass --docker-email=mage@magedu.com
```

## Step6: Secret存储卷

类似于Pod资源使用ConfigMap对象的方式，Secret对象可以注入为容器环境变量，也能够通过Secret卷插件定义为存储卷并由容器挂载使用。但建议使用存储卷形式，以免导致信息泄露。

```yaml
# Created-By:"MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: secrets-volume-demo
spec:
  containers:
  - image: nginx:alpine
    name: ngxserver
    volumeMounts:
    - name: nginxcerts
      mountPath: /etc/nginx/certs/
      readOnly: true
    - name: nginxconfs
      mountPath: /etc/nginx/conf.d/
      readOnly: true
      volumes:
  - name: nginxcerts
    secret:
      secretName: nginx-ssl-secret
  - name: nginxconfs
    configMap:
      name: nginx-sslvhosts-confs
      optional: false
```


首先，基于nginx-ssl-conf.d目录下的配置文件，生成configmaps/nginx-sslvhosts-confs资源对象。

```bash
kubectl create configmap nginx-sslvhosts-confs --from-file=./nginx-ssl-conf.d/
```

而后，运行如下命令，创建Pod对象secrets-volume-demo。

```bash
kubectl apply -f secrets-volume-demo.yaml
```

而后，向该Pod对象的IP地址使用“openssl s_cleint”命令发起TLS访问请求，确认其证书是否为前面自签生成的测试证书。

```bash
podIP=$(kubectl get pods secrets-volume-demo -o jsonpath={.status.podIP})
kubectl run pod-$RANDOM --image="ikubernetes/admin-box:v1.1" --restart=Never --env="podIP=$podIP" --rm -it --command -- /bin/sh
```

```bash
openssl s_client -connect $podIP:443 -state
```

其返回的信息中通常包含类似如下内容。

```console
CONNECTED(00000003)
SSL_connect:before SSL initialization
SSL_connect:SSLv3/TLS write client hello
SSL_connect:SSLv3/TLS write client hello
Can't use SSL_get_servername
SSL_connect:SSLv3/TLS read server hello
depth=0 C = CN, ST = Beijing, L = Beijing, O = DevOps, CN = www.magedu.com
verify error:num=18:self signed certificate
verify return:1
depth=0 C = CN, ST = Beijing, L = Beijing, O = DevOps, CN = www.magedu.com
verify return:1
......
```

上面的测试请求使用了IP地址而非证书中的主体名称“www.magedu.com”，因而证书的验证会失败，但我们只需关注证书内容即可，尤其是证书链中显示的信息。

## Step7：清理创建的所有Pod对象

执行如下命令，查看创建的Pod资源。

```bash
kubectl get pods
```

确认测试完成后，即可删除所有的Pod对象。

```bash
kubectl delete pods --all --force --grace-period=0
```

- 恭喜你完成本教程，欢迎继续挑战后面的其它实验场景~~
- 关于存储卷的更详细介绍，请参阅《Kubernetes进阶实战(第2版)》第6章。


### 参考资料：
1. 《Kubernetes进阶实战(第2版)》
2. 《Kubernetes进阶实战(第2版)》随书[源码](https://github.com/iKubernetes)
3. Kubernetes项目官方文档
4. 搜索引擎搜索到的其它资料
