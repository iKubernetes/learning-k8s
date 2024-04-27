# 单体模式的Loki测试环境

依赖于Docker和Docker Compose，由Docker Compose编排运行Loki、Grafana、MinIO和Promtail几个组件。

Loki Server的关键配置，在于“-target=all”。

```yaml
services:
  loki:
    image: grafana/loki:2.9.7
    command: "-config.file=/etc/loki/config.yaml -target=all"
    ports:
      - 3100:3100
      - 7946
      - 9095
    volumes:
      - ./loki-config.yaml:/etc/loki/config.yaml
    depends_on:
      - minio
    healthcheck:
      test: [ "CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3100/ready || exit 1" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks: &loki-dns
      loki:
        aliases:
          - gateway

```



