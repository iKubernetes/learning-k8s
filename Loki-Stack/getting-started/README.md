# Loki 快速入门与实践

You can use this `docker-compose` setup to run Docker for development or in production.

## Features

- [Minio](https://min.io/) for S3-compatible storage for chunks & indexes
- Promtail for logs
  - 三个可选的日志生成器
    - loggen-json：JSON格式的日志
    - loggen-apache-common：文本日志，apache common格式
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



## LogQL示例

### 标签匹配器

查询指定容器中的日志行

```
{filename="/var/log/generated-logs.txt"} 
{container="getting-started_loggen-apache_1"} 
```

查询满足label matcher所有过滤条件的日志行

```
{filename="/var/log/generated-logs.txt", http_status=~"(4|5).."} 
```

### 行过滤器

进行日志行过滤，显示“user-identifier”不为“-”的日志行

```
{filename="/var/log/generated-logs.txt", http_status=~"(4|5).."} !~ "\"user-identifier\":\"-\""
```

进行日志行过滤，显示“user-identifier”不为“-”，且协议为“HTTP/2.0”的日志行

```
{filename="/var/log/generated-logs.txt", http_status=~"(4|5).."} !~ "\"user-identifier\":\"-\"" |= "\"protocol\":\"HTTP/2.0\""
```



### 标签过滤器

进行日志行过滤，打印“user-identifier”不为“-”，且标签http_method的值为PUT或DELETE的行。

```
{filename="/var/log/generated-logs.txt", http_status=~"(4|5).."} !~ "\"user-identifier\":\"-\"" | http_method=~"PUT|DELETE"
```

#### 解析器

pattern解析器示例：apache combined日志解析

```
{container="getting-started_loggen-apache_1"} | pattern "<ip> - <user> <_> \"<method> <uri> <_>\" <status> <size> <_> \"<agent>\" <_>"
```



示例：基于解析生成的标签过滤日志行

```
{container="getting-started_loggen-apache_1"} | pattern "<ip> - <user> <_> \"<method> <uri> <_>\" <status> <size> <_> \"<agent>\" <_>" | login =~ ".*jenkins.*"
```



regexp解析器示例：apache combined日志解析

```
{container="getting-started_loggen-apache_1"} | regexp "^(?P<remote_host>\\S+) (?P<user_identifier>\\S+) (?P<user>\\S+) \\[(?P<ts>[^\\]]+)\\] \"(?P<request>[^\"]+)\" (?P<status>\\d+) (?P<bytes_sent>\\d+) \"(?P<referer>[^\"]+)\" \"(?P<user_agent>[^\"]+)\"$"
```





## 版权声明

本文档由[马哥教育](http://www.magedu.com/)开发，允许自由转载，但必须保留马哥教育及相关的一切标识。另外，商用需要征得马哥教育的书面同意。
