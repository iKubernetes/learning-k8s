# Helm Wordpress


### MySQL

    helm install mysql bitnami/mysql --set auth.rootPassword=[ROOT_PASSWORD] --set primary.persistence.storageClass=[EXISTING_SC]


    helm install mysql bitnami/mysql --set auth.rootPassword=[ROOT_PASSWORD] -set primary.persistence.storageClass=[EXISTING_SC] --set auth.database=[DB_NAME] --set auth.username=[USER_NAME] --set auth.password=[PASSWORD]

  helm repo add bitnami https://charts.bitnami.com/bitnami

  kubectl create namespace blog

    helm install mysql  \
        --set auth.rootPassword=MageEdu \
        --set primary.persistence.storageClass=nfs-csi \
        --set auth.database=wpdb \
        --set auth.username=wpuser \
        --set auth.password='magedu.com' \
        bitnami/mysql \
        -n blog

    带从节点：
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

### Wordpress
  
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
