# 部署Wordpress

说明：本示例中的wordpress依赖于基于OpenEBS的nfs provider实现支持RWX访问模式的PV，存储类的名称为openebs-rwx；mysql依赖于基于OpenEBS默认的openbs-hostpath存储类。

而后，运行如下命令，即可完成部署。

```bash
kubectl apply -f ./
```



