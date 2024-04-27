# Promtail示例

基于Promtail发现、抓取主机或容器上的日志，并发送给loki server。

本示例中，loki server的访问入口由“simple-scalable”示例中的loki-gateway提示，它通过宿主机的80和3100端口对外暴露Loki Server的API，因此，请确保将当前示例目录下docker-compose.yaml文件中的的promtail service的主机名称解析到正确的地址上。

### 运行方式

```bash
docker-compose build
docker-compose up -d
```

