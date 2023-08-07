# Helm Wordpress


## MySQL

### 基于bitnami仓库的部署

    helm install mysql bitnami/mysql --set auth.rootPassword=[ROOT_PASSWORD] --set primary.persistence.storageClass=[EXISTING_SC]

    helm install mysql bitnami/mysql --set auth.rootPassword=[ROOT_PASSWORD] -set primary.persistence.storageClass=[EXISTING_SC] --set auth.database=[DB_NAME] --set auth.username=[USER_NAME] --set auth.password=[PASSWORD]

  helm repo add bitnami https://charts.bitnami.com/bitnami

  kubectl create namespace blog

  单节点模式：
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

    带从节点：
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

    带从节点：
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
        -n blog \
        --create-namespace
```

## Wordpress
  
### 基于bitnami仓库部署

  kubectl create namespace blog

        自带的MariaDB:

            helm install wordpress \
                --set wordpressUsername=wpuser \
                --set wordpressPassword='magedu.com' \
                --set mariadb.auth.rootPassword=secretpassword \
                bitnami/wordpress

        外部的数据：
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
                -n blog


        外部的数据，支持Ingress，且使用的mysql支持主从架构：
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
                -n blog

### 基于dockerhub上的oci仓库部署

	使用外部的MySQL数据库，且其访问路径为：mysql-primary.blog.svc.cluster.local，部署方式请参考MySQL部署示例。

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
            -n blog \
            --create-namespace
```
