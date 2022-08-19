# 在Pod中运行应用

版权声明：该文档由[马哥教育](http://www.magedu.com)原创，未经书面允许，严禁转载，严禁一切形式的商业用途。

## 实验介绍

在本实验中，我们会带你学习Kubernetes中应用运行的原子单元Pod组件的基础用法，这包括：

- 基于Pod资源规范定义并于Kubernetes集群上运行一个自主式Pod资源；
- 获取Pod及容器的状态信息；
- 在容器的交互式终端中运行其它程序；
- 自定义要运行的容器应用及参数；
- 在容器上使用环境变量进行应用配置；
- 管理容器进程的运行身份；
- 管理容器的内核功能；
- 删除Pod资源对象；

## Step1：创建并运行自主式Pod资源

Pod对象的核心职责在于以主容器形式运行单个应用，因而定义Pod资源的关键配置就在于定义该类型的容器。在Pod的资源规范中，容器以对象形式定义于Pod对象的spec.containers字段中。下面就是一个简单的Pod资源清单，创建于Kubernetes集群上之后，该Pod对象将位于默认的default名称空间，且仅运行一个由ikubernetes/demoapp:v1.0 镜像启动的名为demo的容器。 

```
# Created-By:"MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: pod-demo
spec:
  containers:
  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    </tutorial-editor-copy-file>
```

下面我们来部署该Pod对象并进行一些基础操作。

首先，创建pod-demo.yaml文件，内容如上面的资源清单所示。

而后，执行如下命令，部署清单中定义的自主式Pod资源pod-demo。

```bash
kubectl apply -f pod-demo.yaml
```

执行如下命令，可用监视Pod资源的创建结果及运行状态。

```bash
kubectl get pods/pod-demo -w
```

```console
   NAME       READY    STATUS  RESTARTS  AGE
   pod-demo    1/1     Running    0      5s
```

不再需要对该资源进行监视时，可键入“Ctrl+C”组合的快捷键停止监视。


下面的命令能够打印出pods/pod-demo资源在集群上生成的详细资源规范，以及该资源的实际状态信息。

```bash
kubectl get pods/pod-demo -o yaml
```

资源的详细状态信息，也可由describe命令输出为另一种格式。

```bash
kubectl describe pods/pod-demo
```

接下来，我们测试访问Pod中由demo容器运行的应用服务。由镜像ikubernetes/demoapp启动的容器默认运行了一个Web服务程序，该服务监听于TCP协议的80端口，镜像可通过/、/hostname、/user-agent、/livez、/readyz和/configs等路径服务于客户端的请求。例如，下面的命令先获取到Pod的IP地址，而后对其支持的web资源路径/和/user-agent分别发出了一个访问请求。

我们先使用如下命令获取pods/pod-demo的IP地址，并启动一个测试专用的交互式Pod，将该IP地址以环境变量形式注入到容器中，以便于向pods/pod-demo发起服务访问请求。

下面，我们打开一个新的terminal运行如下命令以进行测试。

```bash
podIP=$(kubectl get pods/pod-demo -o jsonpath={.status.podIP})
kubectl run pod-$RANDOM --image="ikubernetes/admin-box:v1.0" --restart=Never --env=podIP=$podIP --rm -it --command -- /bin/sh
```

而后，在打开的交互式接口中，测试对Pod中服务的访问请求。

```bash
curl -s http://$podIP/
curl -s http://$podIP/user-agent
```

回到此前的termial，或者打开一个新的termial继续后面的测试。

我们也可以在Pod的容器上运行其它命令，以获取信息或进行调试操作。例如，下面的命令可查看该容器中的应用监听的地址和端口等信息。

```bash
kubectl exec pods/pod-demo -c demo -it -- netstat -tnlp
```

## Setp2：定制要运行的容器应用及参数

Pod配置中，spec.containers[].command字段能够在容器上指定不同于镜像默认运行的应用程序，且可同时使用spec.containers[].args字段进行参数传递，它们将覆盖镜像中的默认定义的参数。若定义了args字段，该字段值将作为参数传递给镜像中默认指定运行的应用程序；而仅定义了command字段时，其值将覆盖镜像中定义的程序及参数。

首先，创建pod-demo-with-cmd-and-args.yaml文件。

```yaml
   # Created-By:"MageEdu <mage@magedu.com>"
   apiVersion: v1
   kind: Pod
   metadata:
     name: pod-demo-with-cmd-and-args
   spec:
     containers:
     - name: demo
       image: ikubernetes/demoapp:v1.0
       imagePullPolicy: IfNotPresent
       command: ['/bin/sh','-c']
       args: ['python3 /usr/local/bin/demo.py -p 8080']
```

上面的资源配置清单中，我们把镜像ikubernetes/demoapp:v1.0的默认应用程序修改为了”/bin/sh -c“，参数定义为”python3 /usr/local/bin/demo.py -p 8080“，其中的-p选项用于修改服务监听的端口为指定的自定义端口。

执行如下命令，部署清单中定义的自主式Pod资源pod-demo-with-cmd-and-args。

```bash
kubectl apply -f pod-demo-with-cmd-and-args.yaml
```

执行如下命令，查看Pod资源的创建结果及运行状态。

```bash
kubectl get pods/pod-demo-with-cmd-and-args
```

执行如下命令，了解demoapp的运行状态。

```bash
kubectl exec pod-demo-with-cmd-and-args -- netstat -tnl  
```

```console
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address    Foreign Address     State 
tcp        0      0 0.0.0.0:8080     0.0.0.0:*          LISTEN 
```


## Step3：在Pod上使用环境变量进行应用配置


向Pod中的容器注入环境变量的常用方法有env和envFrom两种，它们定义在容器配置段中。其中，通过env字段定义的环境变量的值是一个列表，每个列表项由name（环境变量名称）和value（向环境变量传递的值）两个内嵌字段构成。

首先，创建pod-using-env.yaml文件，通过环境变量配置demoapp。

```yaml
# Created-By:"MageEdu <mage@magedu.com>"

apiVersion: v1
kind: Pod
metadata:
  name: pod-using-env
spec:
  containers:
  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    env:
    - name: HOST
      value: "127.0.0.1"
    - name: PORT
      value: "8080"
```

示例中使用镜像demoapp中的应用服务器支持通过HOST和PORT环境变量分别获取监听的地址和端口，它们的默认值分别为“0.0.0.0”和“80”。

执行如下命令，部署清单中定义的自主式Pod资源pod-using-env。

```bash
kubectl apply -f pod-using-env.yaml
```

执行如下命令，查看Pod资源的创建结果及运行状态。

```bash
kubectl get pods/pod-using-env
```

执行如下命令，了解demoapp的运行状态。

```bash
kubectl exec pod-using-env -- netstat -tnl
```

```console
   Active Internet connections (only servers)
   Proto Recv-Q Send-Q Local Address      Foreign Address    State       
   tcp        0      0 127.0.0.1:8080     0.0.0.0:*         LISTEN
```


## Step4: 容器安全上下文 

Kubernetes为安全运行Pod及容器运行设计了安全上下文（Security Context）机制，该机制允许用户和管理员定义Pod或容器的特权和访问控制，以配置容器与主机以及主机之上的其他容器间的隔离级别。安全上下文就是一组用来决定容器是如何创建和运行的约束条件，这些条件代表创建和运行容器时使用的运行时参数。

Kubernetes支持用户在Pod及容器级别配置安全上下文，并允许管理员通过Pod安全策略（Pod Security Policy）在集群全局级别限制用户在创建和运行Pod时可设定的安全上下文。本步骤仅描述Pod和容器级别的配置。

下面的资源清单中配置以1001这个UID和GID的身份来运行容器中的demoapp应用，考虑到非特权用户默认无法使用1024以下的端口号，文件中通过环境变量改了应用监听的端口。首先，我们复制如下内容，保存于名为securitycontext-runasuer-demo.yaml的资源文件中。

```yaml
# Created-By:"MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: securitycontext-runasuser-demo
spec:
  containers:
  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    env:
    - name: PORT
      value: "8080"
      securityContext:
      runAsUser: 1001
      runAsGroup: 1001
```

执行如下命令，部署清单中定义的自主式Pod资源securitycontext-runasuser-demo。

```bash
kubectl apply -f securitycontext-runasuer-demo.yaml
```

查看demo容器中运行相关进程的真实用户身份。

```bash
kubectl exec securitycontext-runasuser-demo -- id 
```

该命令会显示如下内容。
```console
id=1001 gid=1001
```

下面的命令则使用ps直接查看进程相关的属性信息。
```bash
kubectl exec securitycontext-runasuser-demo -- ps aux
```

该命令会输出类似如下内容。
```console
PID   USER     TIME  COMMAND
  1    1001      0:00  python3 /usr/local/bin/demo.py
```


## Step5：管理容器的内核功能

为Kubernetes上运行的进程设定内核功能则需要于Pod内容器上的安全上下文中嵌套capabilities字段实现，添加和移除内核能力还需要分别再向下一级嵌套使用add或drop字段。这两个字段可接受以内核能力名称为列表项，但引用各内核能力名称时需将移除CAP_前缀，例如可使用NET_ADMIN和NET_BIND_SERVICE这样的功能名称。

下面的配置清单中定义的Pod对象的demo容器，在安全上下文中启用了内核功能NET_ADMIN，并禁用了CHOWN。demo容器的镜像未定义USER指令，它默认将以root用户的身份运行容器应用。首先，我们复制如下内容，保存于名为securitycontext-capabilities-demo.yaml的资源文件中。

```yaml
# Created-By:"MageEdu <mage@magedu.com>"
apiVersion: v1
kind: Pod
metadata:
  name: securitycontext-capabilities-demo
spec:
  containers:

  - name: demo
    image: ikubernetes/demoapp:v1.0
    imagePullPolicy: IfNotPresent
    command: ["/bin/sh","-c"]
    args: ["/sbin/iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-port 80 && /usr/bin/python3 /usr/local/bin/demo.py"]
    securityContext:
      capabilities:
        add: ['NET_ADMIN']
        drop: ['CHOWN']
```

运行如下命令，把该Pod对象创建并运行于集群上来验证清单中的配置。

```bash
kubectl apply -f securitycontext-capabilities-demo.yaml  
```

检查Pod网络名称空间中netfilter之上的规则，清单中的iptables命令添加的规则位于nat表的PREROUTING链上。

```bash
kubectl exec securitycontext-capabilities-demo -- iptables -t nat -nL PREROUTING 
```

该命令全输出类似如下结果，它表示iptables命令已然生成的规则，NET_ADMIN功能启用成功。

```console
Chain PREROUTING (policy ACCEPT)
target     prot    opt    source        destination         
REDIRECT   tcp  --  0.0.0.0/0         0.0.0.0/0       tcp dpt:8080 redir ports 80
```

验证CHOWN内核功能的禁用效果。

```bash
kubectl exec securitycontext-capabilities-demo -- chown 200.200 /etc/hosts
```

类似如下命令结果表示，其CHOWN功能已然成功关闭。

```console
chown: /etc/hosts: Operation not permitted
command terminated with exit code 1
```


## Step6：删除Pod资源

执行如下命令，查看创建的Pod资源。

```bash
kubectl get pods
```

```console
   NAME                          READY   STATUS    RESTARTS   AGE
   pod-demo                      1/1     Running   0          23m
   pod-with-cmd-and-args         1/1     Running   0          15m
   pod-using-env                 1/1     Running   0          7m
   ...
```

确认测试完成后，且不再需要这些Pod，可执行如下命令，删除创建的所有Pod资源以释放系统资源。

```bash
kubectl delete pods --all --force --grace-period=0
```

- 恭喜你完成本教程，欢迎继续挑战后面的其它实验场景~~
- 关于Pod的更详细介绍，请参阅《Kubernetes进阶实战(第2版)》第4章。

### 参考资料：
1. 《Kubernetes进阶实战(第2版)》
2. 《Kubernetes进阶实战(第2版)》随书[源码](https://github.com/iKubernetes)
3. Kubernetes项目官方文档
4. 搜索引擎搜索到的其它资料
