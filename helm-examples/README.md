# Helm应用部署示例

Helm 被广泛类比为 Kubernetes 的 "包管理器"，类似于 Linux 系统的apt或yum组件。它通过 Chart（预配置的Kubernetes资源包）将复杂的应用部署抽象为可复用的模块，支持版本控制、依赖管理和跨环境部署。

### Helm的相关概念

**关键概念**

1. Chart
   - 结构：包含Chart.yaml（元数据）、values.yaml（默认配置）、templates/（资源模板）等目录。
   - 子Chart：通过 charts/ 目录或dependencies字段声明依赖的其他Chart。
2. Release
   - 代表Chart 在集群中的具体实例。例如，同一个Chart可多次部署为不同Release（如开发环境dev和生产环境prod）。
3. Repository
   - HTTP 服务器托管Chart包和索引文件（index.yaml）。用户可发布自定义 Chart 到仓库供团队共享。
   - [Artifact Hub](https://artifacthub.io])是云原生计算基金会（CNCF）托管的云原生制品中心化仓库，它通过集中索引和分类，帮助用户快速查找、安装和发布各类云原生资源，如 Helm Chart、安全策略、插件等。
4. Values
   - 动态配置参数，允许用户覆盖Chart的默认值。例如，通过 --set image.tag=latest 在安装时指定镜像版本。

**工作机制**

Chart处理流程：

- **模板渲染**：将 Chart 中的模板文件（如deployment.yaml.tpl）与用户提供的 values.yaml 合并，生成标准的Kubernetes资源配置文件。
- **与 Kubernetes API 交互**：Helm CLI直接通过kubeconfig连接 Kubernetes API Server，提交渲染后的资源文件完成部署（Helm 3移除了服务端组件Tiller，简化了架构并提升安全性）。

Release管理：每次安装或升级生成一个 Release 实例，其状态（如配置、版本号）存储在 Kubernetes 的 Secret 或 ConfigMap 中，便于历史记录查询和回滚。

### 应用部署示例

部署Ingress Nginx，并启用内置的Metrics。

```bash
helm upgrade ingress-nginx ingress-nginx \
	--repo https://kubernetes.github.io/ingress-nginx \
	--namespace ingress-nginx \
	--set controller.metrics.enabled=true \
	--set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
	--set-string controller.podAnnotations."prometheus\.io/port"="10254"
```

部署OpenEBS，并禁用了本地的zfs和lvm存储引擎，以及复制引擎Mayastor。

```bash
helm install openebs --namespace openebs openebs/openebs --set engines.replicated.mayastor.enabled=false \
            --set engines.local.zfs.enabled=false --set engines.local.lvm.enabled=false --create-namespace
```

> 提示：OpenEBS 4.x系列，目前的Chart并不支持使用“--set nfs-provisioner.enabled=true”选项来启用nfs provisioner，需要该功能时，建议额外使用下面的命令进行手动部署。
>
> ```bash
> kubectl apply -f https://openebs.github.io/charts/nfs-operator.yaml
> ```









