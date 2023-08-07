# Nacos
提示：Nacos需要先完成数据库初始化，而后才能正常运行。数据库初始化的方式有两种：
- 使用非Nacos提供的MySQL数据库镜像，需要手动运行sql脚本；
    脚本地址：https://raw.githubusercontent.com/alibaba/nacos/develop/distribution/conf/mysql-schema.sql
- 使用由Nacos提供的MySQL镜像，能自动完成数据库初始化；

说明：本示例中的Nacos依赖于一个部署完成的MySQL，且它默认访问的是主从架构MySQL服务中的主节点“mysql-0.mysql“，因此，需要事先手动进行Nacos数据库初始化。

