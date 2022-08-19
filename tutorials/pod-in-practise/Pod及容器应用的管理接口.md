# Pod及容器应用的管理接口

版权声明：该文档由[马哥教育](http://www.magedu.com)原创，未经书面允许，严禁转载，严禁一切形式的商业用途。

## 实验介绍

监测容器自身运行的API包括分别用于健康状态检测、指标、分布式跟踪和日志等实现类型。即便没有完全实现，至少容器化应用也应该提供用于健康状态检测（liveness和readiness）的API，以便编排系统能更准确地判定应用程序的运行状态。在本实验场景中，我们会带你学习Kubernetes中容器应用的管理接口，这包括：

- 容器存活探针exec
- 容器存活探针httpGet
- 容器存活探针tcpSocket
- 容器就绪探针httpGet
- 容器的postStart钩子
- 容器的preStop钩子

## Step1: 容器exec存活探针

exec类型的探针通过在目标容器中执行由用户自定义的命令来判定容器的健康状态，命令状态返回值为0表示“成功”通过检测，其值均为“失败”状态。具体的配置定义在Pod的spec.containers.livenessProbe.exec字段上，该字段只有一个可用属性“command”，用于指定要执行的命令

demoapp应用程序通过/livez输出内置的存活状态检测接口，服务正常时，它以200响应码返回OK，否则则响应以5xx响应码，我们可基于exec探针使用http客户端向该path发起请求并根据命令的结果状态来判定健康与否的状态。系统刚启动时，对该路径的请求将会延迟大约不到5秒钟的时长，且默认响应值为OK。它还支持由用户根据需要向该路径发起POST请求，并向参数livez传值来自定义其响应内容。

复制如下配置保存于资源清单文件中，例如liveness-exec-demo.yaml。

```yaml
# Created-By: "MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: liveness-exec-demo
spec:
  containers:
  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    livenessProbe:
      exec:
        command: ['/bin/sh', '-c', '[ "$(curl -s 127.0.0.1/livez)" == "OK" ]']
      initialDelaySeconds: 5
      periodSeconds: 5
```

运行如下命令，创建Pod对象liveness-exec-demo。

```bash
kubectl apply -f liveness-exec-demo.yaml
```

查看pods/liveness-exec-demo中容器上的存活探针信息。

```bash
kubectl describe pods/liveness-exec-demo
```

该命令会输出Pod资源的详细描述信息，其中容器状态信息时会有如下类似段的显示，其中的Liveness即为定义的exec检测探针。

```console
Containers:
  demo:
    Container ID:   docker://dc3a493ae8b23db1ee011a6b408bc60e108a3664927cead69048caf03574515f
    Image:          ikubernetes/demoapp:v1.0
    Image ID:       docker-pullable://ikubernetes/demoapp@sha256:6698b205eb18fb0171398927f3a35fe27676c6bf5757ef57a35a4b055badf2c3
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 02 Apr 2022 04:48:46 +0000
    Ready:          True
    Restart Count:  0
    Liveness:       exec [/bin/sh -c [ "$(curl -s 127.0.0.1/livez)" == "OK" ]] delay=5s timeout=1s period=5s #success=1 #failure=3
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-qbsw8 (ro)
```


接下来，我们手动将/livez的响应内容修改为OK之外的其他值，例如FAIL，以便于测试健康探针失败的后果。

```bash
kubectl exec liveness-exec-demo -- curl -s -X POST -d 'livez=FAIL' 127.0.0.1/livez
```

经过3个检测周期后，使用如下命令通过Pod对象的描述信息来获取相关的事件状态。

```bash
kubectl describe pods/liveness-exec-demo
```

遇到健康状态检测失败后，该命令会输出的类似如下结果中，Containers一段中清晰显示了容器健康状态检测及状态变化的相关信息：容器当前处于Running状态，但前一次是为Terminated，原因是退出码为137的错误信息，它表示进程是被外部信号所终止。137事实上由两部分数字之和生成：128+signum，其中signum是导致进程终止的信号的数字标识，9表示SIGKILL，这意味着进程是被强行终止。

```console
Containers:
  demo:
    Container ID:   docker://b6469b9ae2ed6e54ee0f69ffc8cc774de54d413663a99add479c046957b5c4f7
    Image:          ikubernetes/demoapp:v1.0
    Image ID:       docker-pullable://ikubernetes/demoapp@sha256:6698b205eb18fb0171398927f3a35fe27676c6bf5757ef57a35a4b055badf2c3
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 02 Apr 2021 04:52:58 +0000
    Last State:     Terminated
      Reason:       Error
      Exit Code:    137
      Started:      Fri, 02 Apr 2021 04:48:46 +0000
      Finished:     Fri, 02 Apr 2021 04:52:58 +0000
    Ready:          True
    Restart Count:  1
    Liveness:       exec [/bin/sh -c [ "$(curl -s 127.0.0.1/livez)" == "OK" ]] delay=5s timeout=1s period=5s #success=1 #failure=3
    Environment:    <none>
```


**存活探针的失败探测次数达到定义或默认的阈值时，会导致容器重启。**


## Step2：容器httpGet存活探针

HTTP探针基于http协议的探测（HTTPGetAction）通过向目标容器发起一个GET请求，并根据其响应码进行结果判定，2xx或3xx类的响应码则表示检测通过。下面的示例清单中，容器上配置使用了HTTP探针直接对/livez发起访问请求，并根据其响应码来判定检测结果。

我们首先复制下面的内容保存于资源清单文件中，例如liveness-httpget-demo.yaml。

```yaml
# Created-By: "MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: liveness-httpget-demo
spec:
  containers:
  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    livenessProbe:
      httpGet:
        path: '/livez'      # 请求的主机地址，默认为pod IP；也可以在httpHeaders使用“Host: ”来定义
        port: 80            # 请求的端口，必选字段
        scheme: HTTP        # 建立连接使用的协议，仅可为HTTP或HTTPS，默认为HTTP
      initialDelaySeconds: 5
```


运行如下命令，创建Pod对象liveness-httpget-demo。

```bash
kubectl apply -f liveness-httpget-demo.yaml
```

首次检测为延迟5秒，这刚好超过了demoapp的/livez接口默认会延迟响应的时长。镜像中定义的默认响应是以200状态码响应以OK为结果，存活状态检测会成功完成。为了测试存活状态检测的效果，同样可以手动将/livez的响应内容修改为OK之外的其他值，例如FAIL。

```bash
kubectl exec liveness-httpget-demo -- curl -s -X POST -d 'livez=FAIL' 127.0.0.1/livez
```

而后经过至少3个检测周期后，可通过Pod对象的描述信息来获取相关的事件状态。

```bash
kubectl describe pods/liveness-httpget-demo
```

遇到健康状态检测失败后，该命令会输出的类似如下结果的意义同前一节中的exec探针相似。

```console
Containers:
  demo:
    Container ID:   docker://28c9373934f71530643b3181080ee4b7d4502937f748f544ce9ba63cfd4268ff
    Image:          ikubernetes/demoapp:v1.0
    Image ID:       docker-pullable://ikubernetes/demoapp@sha256:6698b205eb18fb0171398927f3a35fe27676c6bf5757ef57a35a4b055badf2c3
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 02 Apr 2021 04:57:14 +0000
    Last State:     Terminated
      Reason:       Error
      Exit Code:    137
      Started:      Fri, 02 Apr 2021 04:56:18 +0000
      Finished:     Fri, 02 Apr 2021 04:57:14 +0000
    Ready:          True
    Restart Count:  1
    Liveness:       http-get http://:80/livez delay=5s timeout=1s period=10s #success=1 #failure=3
    Environment:    <none>
```


## Step3：容器tcpSocket存活探针

TCP探针是基于TCP协议进行存活性探测（TCPSocketAction），通过向容器的特定端口发起TCP请求并尝试建立连接进行结果判定，连接建立成功即为通过检测。Pod资源规范上的spec.containers.livenessProbe.tcpSocket字段用于定义此类检测。下面的示例清单中，容器上配置使用了TCP探针直接对80端口发起访问请求，并根据其响应码来判定检测结果。

我们首先复制下面的内容保存于资源清单文件中，例如liveness-tcpsocket-demo.yaml。

```yamll
# Created-By: "MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: liveness-tcpsocket-demo
spec:
  containers:
  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    ports:
    - name: http
      containerPort: 80
      securityContext:
      capabilities:
        add:
        - NET_ADMIN
          livenessProbe:
          tcpSocket:
            port: http
          periodSeconds: 5
          initialDelaySeconds: 20
```

运行如下命令，创建Pod对象liveness-tcpsocket-demo。

```bash
kubectl apply -f liveness-tcpsocket-demo.yaml
```

容器应用demoapp启动后即监听于TCP协议的80端口，TCP探针也就可以成功执行。为了测试效果，可使用下面的命令在Pod的Network名称空间中设置iptables规则以阻止对80端口的请求：

```bash
kubectl exec liveness-tcpsocket-demo -- iptables -A INPUT -p tcp --dport 80 -j REJECT
```

而后经过至少3个检测周期后，可通过Pod对象的描述信息来获取相关的事件状态。

```bash
kubectl describe pods/liveness-tcpsocket-demo
```

遇到健康状态检测失败后，该命令会输出的类似如下结果的意义同样跟前面的exec探针相似，但它使用的是tcpSocket探针。

```console
Containers:
  demo:
    Container ID:   docker://4edb9824460edf89f090dc7df60b036886e630a430723516fbfa5293e1359ecc
    Image:          ikubernetes/demoapp:v1.0
    Image ID:       docker-pullable://ikubernetes/demoapp@sha256:6698b205eb18fb0171398927f3a35fe27676c6bf5757ef57a35a4b055badf2c3
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Fri, 02 Apr 2021 05:00:13 +0000
    Last State:     Terminated
      Reason:       Error
      Exit Code:    137
      Started:      Fri, 02 Apr 2021 04:59:07 +0000
      Finished:     Fri, 02 Apr 2021 05:00:13 +0000
    Ready:          True
    Restart Count:  1
    Liveness:       tcp-socket :http delay=20s timeout=1s period=5s #success=1 #failure=3
    Environment:    <none>
```


## Step4：容器的httpGet就绪探针

就绪状态探测是用来判断容器应用就绪与否周期性（默认周期为10秒钟）操作，它用于探测容器是否已经初始化完成并可服务于客户端请求。与存活探针触发的操作不同，探测失败时，就绪探针不会杀死或重启容器来确保其健康状态，而仅仅是通知其尚未就绪，并触发依赖于其就绪状态的其他操作（例如从Service对象中移除此Pod对象）以确保不会有客户端请求接入此pod对象。

就绪探针也支持Exec、HTTP GET和TCP Socket三种探测方式，且它们各自的定义机制与存活探针相同。因而，将容器定义中的livenessProbe字段名替换readinessProbe并略作适应性修改即可定义出就绪性探测的配置来，甚至有些场景中的就绪探针与存活探针的配置可以完全相同。

demoapp应用程序通过/readyz暴露了专用于就绪状态检测的接口，它于程序启动约15秒后能够以200状态码响应内容“OK”，也支持用户通过POST请求方法通过readyz参数传递自定义的响应内容，不过，所有非“OK”的响应内容都被响应以5xx的状态码。

```yaml
# Created-By: "MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: readiness-httpget-demo
spec:
  containers:
  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    readinessProbe:
      httpGet:
        path: '/readyz'
        port: 80
        scheme: HTTP
      initialDelaySeconds: 15
      timeoutSeconds: 2
      periodSeconds: 5
      failureThreshold: 3
      restartPolicy: Always
```

运行如下命令，创建Pod对象readiness-httpget-demo。

```bash
kubectl apply -f readiness-httpget-demo.yaml
```

接着运行kubectl get -w命令监视其资源变动信息，由如下命令结果可知，尽管Pod对象处于Running状态，但直到就绪探测命令执行成功后Pod资源才转为“就绪”。

```bash
kubectl get pods/readiness-httpget-demo -w
```

该Pod在持续运行一段时间后，待首次就绪探针检测成功通过，其状态才会转为“Ready”，如下面的命令结果所示。

```console
NAME                     READY   STATUS    RESTARTS   AGE
readiness-httpget-demo   0/1     Running   0          6s
readiness-httpget-demo   1/1     Running   0          31s
```

监视完成后，可使用“Ctrl+C”快捷键退出。

Pod运行过程中的某一时刻，无论因各种原因导致的就绪状态探测的连续失败都会使得该Pod从就绪状态转变为“未就绪”，并且会从各个通过标签选择器关联至该Pod对象的Service后端端点列表中删除。为了测试就绪状态探测效果，下面修改/readyz响应以非‘OK’内容。

```bash
kubectl exec readiness-httpget-demo -- curl -s -X POST -d 'readyz=FAIL' 127.0.0.1/readyz
```

在至少3个检测周期后，再次查看Pod状态，其将处于未就绪状态。

```bash
kubectl describe pods/readiness-httpget-demo
```

在相关命令输出中，在一个探测周期后，会输出类似如下结果，其中Ready的值即表示其处于“未就绪”状态。

```console
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   True 
  PodScheduled      True 
```


## Step5：preStart和postStop钩子

容器生命周期钩子使它能够感知其自身生命周期管理中的事件，并在相应的时刻到来时运行由用户指定的处理程序代码。kubernetes为容器提供了PostStart和PreStop两种生命周期挂钩。postStart和preStop处理器定义在容器的lifecycle字段中，其内部一次仅支持嵌套使用一种处理器类型。下面的资源清单中同时使用了preStop和postStart挂钩。

```yaml
# Created-By: "MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    securityContext:
      capabilities:
        add:
        - NET_ADMIN
    livenessProbe:
      httpGet:
        path: '/livez'
        port: 80
        scheme: HTTP
      initialDelaySeconds: 5
    lifecycle:
      postStart:
        exec:
          command: ['/bin/sh','-c','iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-ports 80']
      preStop:
        exec:
          command: ['/bin/sh','-c','while killall python3; do sleep 1; done']
      restartPolicy: Always 
```

运行如下命令，创建Pod对象lifecycle-demo。

```bash
kubectl apply -f lifecycle-demo.yaml
```

而后可获取容器内网络名称空间中PREROUTING链上的iptables规则，验证postStart事件的执行结果。

```bash
 kubectl exec lifecycle-demo -- iptables -t nat -nL PREROUTING
```

命令的执行结果中出现类似如下所示的内容，即表示postStart事件执行完成。

```console
Chain PREROUTING (policy ACCEPT)
target     prot opt     source    destination         
REDIRECT   tcp  --  0.0.0.0/0    0.0.0.0/0    tcp dpt:8080 redir ports 80
```

上面的配置清单中有意同时添加了httpGet类型的存活探针，因而可以人为地将探针检测结果置为失败状态以促使kubelet重启demo容器被来验证preStop事件的执行。不过，该示例中给出的操作是终止容器应用，因而容器重启完成即验证了相应的脚本运行完成。


## Step6：清理创建的所有Pod对象

执行如下命令，查看创建的Pod资源。

```bash
kubectl get pods
```

确认测试完成后，即可删除所有的Pod对象。

```bash
kubectl delete pods --all --force --grace-period=0
```

- 恭喜你完成本教程，欢迎继续挑战后面的其它实验场景~~
- 关于Pod的更详细介绍，请参阅《Kubernetes进阶实战(第2版)》第4章。


### 参考资料：
1. 《Kubernetes进阶实战(第2版)》
2. 《Kubernetes进阶实战(第2版)》随书源码（https://github.com/iKubernetes）
3. Kubernetes项目官方文档
4. 搜索引擎搜索到的其它资料
