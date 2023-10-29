

# Helm 部署 Wordpress

## MySQL

基于bitnami提供的Chart部署MySQL，传统模式是添加bitnami的Chart仓库，而后引用bitnami/mysql这一个Chart进行部署。近来，bitnami将其维护的各项目的Chart托管到了docker hub之上，因此，其Chart的引用方式亦随之发生了变化。如下示例给出了两种场景中的部署方式，而目前通常要使用后面的“基于dockerhub上的oci仓库部署”一节中描述的方法进行部署。

### 基于bitnami仓库的部署

首先，添加bitnami仓库

```bash
 helm repo add bitnami https://charts.bitnami.com/bitnami
```

而后，创建目标名称空间

```bash
kubectl create namespace blog
```

 示例1：部署单节点模式的MySQL：

```bash
helm install mysql  \
        --set auth.rootPassword=MageEdu \
        --set primary.persistence.storageClass=nfs-csi \
        --set auth.database=wpdb \
        --set auth.username=wpuser \
        --set auth.password='magedu.com' \
        bitnami/mysql \
        -n blog
```

示例2：部署主从复制模式的MySQL：

```bash
helm install mysql  \
        --set auth.rootPassword=MageEdu \
        --set global.storageClass=nfs-csi \
        --set architecture=replication \
        --set auth.database=wpdb \
        --set auth.username=wpuser \
        --set auth.password='magedu.com' \
        --set secondary.replicaCount=1 \
        --set auth.replicationPassword='replpass' \
        bitnami/mysql \
        -n blog
```

### 基于dockerhub上的oci仓库部署

部署主从复制模式的MySQL，其功能类似前一小节中的示例2。

```bash
helm install mysql  \
        --set auth.rootPassword='MageEdu' \
        --set global.storageClass=nfs-csi \
        --set architecture=replication \
        --set auth.database=wpdb \
        --set auth.username=wpuser \
        --set auth.password='magedu.com' \
        --set secondary.replicaCount=1 \
        --set auth.replicationPassword='replpass' \
        oci://registry-1.docker.io/bitnamicharts/mysql \
        -n blog --create-namespace
```

## Wordpress

使用bitnami社区的Chart部署Wordpress，其引用方式类似于前一节中的MySQL，这里也分别进行描述。

### 基于bitnami仓库部署

首先，添加bitnami仓库。若该步骤已经完成，则不需要重复执行。

```bash
 helm repo add bitnami https://charts.bitnami.com/bitnami
```

示例1：使用wordpress Chart中自行依赖的MariaDB作为数据库。注意修改如下命令中各参数值，以正确适配到自有环境。

```bash
helm install wordpress \
        --set wordpressUsername=wpuser \
        --set wordpressPassword='magedu.com' \
        --set mariadb.auth.rootPassword=secretpassword \
        bitnami/wordpress \
        -n blog --create-namespace
```

示例2：使用已经部署完成的现有MySQL数据库。注意修改如下命令中各参数值，以正确适配到自有环境。

```bash 
helm install wordpress \
        --set mariadb.enabled=false \
        --set externalDatabase.host=mysql.blog.svc.cluster.local \
        --set externalDatabase.user=wpuser \
        --set externalDatabase.password='magedu.com' \
        --set externalDatabase.database=wpdb \
        --set externalDatabase.port=3306 \
        --set persistence.storageClass=nfs-csi \
        --set wordpressUsername=admin \
        --set wordpressPassword='magedu.com' \
        bitnami/wordpress \
        -n blog --create-namespace
```

示例3：使用已经部署完成的现有MySQL数据库，支持Ingress，且外部的MySQL是主从复制架构。注意修改如下命令中各参数值，以正确适配到自有环境。

```bash
helm install wordpress \
       --set mariadb.enabled=false \
       --set externalDatabase.host=mysql-primary.blog.svc.cluster.local \
       --set externalDatabase.user=wpuser \
       --set externalDatabase.password='magedu.com' \
       --set externalDatabase.database=wpdb \
       --set externalDatabase.port=3306 \
       --set persistence.storageClass=nfs-csi \
       --set ingress.enabled=true \
       --set ingress.ingressClassName=nginx \
       --set ingress.hostname=blog.magedu.com \
       --set ingress.pathType=Prefix \
       --set wordpressUsername=admin \
       --set wordpressPassword='magedu.com' \
       bitnami/wordpress \
       -n blog --create-namespace
```



### 基于dockerhub上的oci仓库部署

下面的命令示例，将使用外部的MySQL数据库，且其访问路径为：mysql-primary.blog.svc.cluster.local。注意修改如下命令中各参数值，以正确适配到自有环境。

```bash
helm install wordpress \
            --set mariadb.enabled=false \
            --set externalDatabase.host=mysql-primary.blog.svc.cluster.local \
            --set externalDatabase.user=wpuser \
            --set externalDatabase.password='magedu.com' \
            --set externalDatabase.database=wpdb \
            --set externalDatabase.port=3306 \
            --set persistence.storageClass=nfs-csi \
            --set ingress.enabled=true \
            --set ingress.ingressClassName=nginx \
            --set ingress.hostname=blog.magedu.com \
            --set ingress.pathType=Prefix \
            --set wordpressUsername=admin \
            --set wordpressPassword='magedu.com' \
            oci://registry-1.docker.io/bitnamicharts/wordpress \
            -n blog --create-namespace
```

### 版权声明

本示例由[马哥教育](http://www.magedu.com)原创，允许自由转载，商用必须经由马哥教育的书面同意。
