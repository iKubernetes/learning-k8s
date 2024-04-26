# Loki 快速入门与实践

You can use this `docker-compose` setup to run Docker for development or in production.

## Features

- [Minio](https://min.io/) for S3-compatible storage for chunks & indexes
- Promtail for logs
  - 两个可选的日志生成器
    - loggen-json：JSON格式的日志
    - loggen-apache-combined：文本日志，apache combined格式

## Getting Started

Simply run `docker-compose up` and all the components will start.

All data will be stored in the `.data` directory.

Grafana runs on port `3000`, and there are Loki & Prometheus datasources enabled by default.

## Endpoints

- [`/ring`](http://localhost:8080/ring) - view all components registered in the hash ring
- [`/config`](http://localhost:8080/config) - view the configuration used by Loki
- [`/memberlist`](http://localhost:8080/memberlist) - view all components in the memberlist cluster
- [all other Loki API endpoints](https://grafana.com/docs/loki/latest/api/)
