# 部署Jenkins
deploy目录中的配置文件，用于将Jenkins部署于Kubernetes集群之上，它依赖于：
- Kubernetes集群上部署有基于nfs-csi的存储服务，且创建了名称为nfs-csi的StorageClass资源
- Kubernetes集群上部署有Ingress Nginx Controller

### 部署命令
```bash
kubectl apply -f deploy/
```

### 用到的pipeline代码示例

第一个：测试于Pod中运行slave
```
// Author: "MageEdu <mage@magedu.com>"
// Site: www.magedu.com
pipeline {
    agent {
        kubernetes {
            inheritFrom 'jenkins-slave'
        }
    }
    stages {
        stage('Testing...') {
            steps {
                sh 'java -version'
            }
        }
    }
}
```

第二个：测试maven构建环境
```
pipeline {
    agent {
        kubernetes {
            inheritFrom 'maven-3.6'
        }
    }
    stages {
        stage('Build...') {
            steps {
                container('maven') {
                    sh 'mvn -version'
                }
            }
        }
    }
}
```

第三个：测试docker in docker环境
```
pipeline {
    agent {
        kubernetes {
            inheritFrom 'maven-and-docker'
        }
    }
    stages {
        stage('maven version') {
            steps {
                container('maven') {
                    sh 'mvn -version'
                }
            }
        }
        stage('docker info') {
            steps {
                container('docker') {
                    sh 'docker info'
                }
            }
        }
    }
}
```

