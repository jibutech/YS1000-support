# Deploy YS1000 in offline environment

## 内容索引

- [环境准备](#环境准备)
- [使用helm部署YS1000](#使用helm部署YS1000)

## 环境准备

这套方案是基于k8s集群的部署，因此需要一个k8s集群，并且提前安装好docker和helm，以及一个私有镜像仓库和一个备份仓库（参见另一篇 https://github.com/jibutech/YS1000-support/blob/main/Deploy%20MinIO%20in%20offline%20envirionment.md ）。

```
# kubectl get nodes
NAME          STATUS   ROLES    AGE    VERSION
test-master   Ready    master   132d   v1.18.9
test-worker   Ready    <none>   132d   v1.18.9

# docker version
Client: Docker Engine - Community
 Version:           19.03.8

# helm version
version.BuildInfo{Version:"v3.5.2", GitCommit:"167aac70832d3a384f65f9745335e9fb40169dc2", GitTreeState:"dirty", GoVersion:"go1.15.7"}
```

## 使用helm部署YS1000

本文中我们将使用已经打包好的helm文件和所有使用到的10个docker image通过替换qiming-values.yaml的参数实现私有化部署。

第一步，将qiming-operator的helm chart(qiming-operator-2.1.0.tgz)和10个image的tar包拷贝到新集群，并导入镜像。
```
# ls
hook-runner.tar     mig-discovery.tar  qiming-operator-2.1.0.tgz  qiming-values.yaml    velero-plugin-for-aws.tar  velero-restic-restore-helper.tar
mig-controller.tar  mig-ui.tar         qiming-operator.tar        velero-installer.tar  velero-plugin-for-csi.tar  velero.tar

# docker load -i hook-runner.tar
...
# docker load -i velero.tar
```

第二步，修改所有镜像的tag为私有镜像仓库地址。
```
# docker tag registry.cn-shanghai.aliyuncs.com/jibudata/velero-restic-restore-helper:v1.7.0 registry.cn-shanghai.aliyuncs.com/ys1000/velero-restic-restore-helper:v1.7.0
...
```

第三步，登陆私有镜像仓库并上传所有镜像。
```
# docker login registry.cn-shanghai.aliyuncs.com

# docker push registry.cn-shanghai.aliyuncs.com/ys1000/velero-restic-restore-helper:v1.7.0
...
```

第四步，修改qiming-value.yaml 中的值替换成私有镜像仓库的repositry。
```
# cat qiming-values.yaml

image:
  repository: registry.cn-shanghai.aliyuncs.com/ys1000/qiming-operator
  pullPolicy: Always
  tag: "v2.1.0"

componentImages:
  uiImage:
    repository: registry.cn-shanghai.aliyuncs.com/ys1000/mig-ui
    tag: "v2.1.0"
  discoveryImage:
    repository: registry.cn-shanghai.aliyuncs.com/ys1000/mig-discovery
    tag: "v2.1.0"
  migControllerImage:
    repository: registry.cn-shanghai.aliyuncs.com/ys1000/mig-controller
    tag: "v2.1.0"
  resticHelperImage:
    repository: registry.cn-shanghai.aliyuncs.com/ys1000/velero-restic-restore-helper
    tag: "v1.7.0"
  veleroInstallerImage:
    repository: registry.cn-shanghai.aliyuncs.com/ys1000/velero-installer
    tag: "v2.1.0"
  hookRunnerImage:
    repository: registry.cn-shanghai.aliyuncs.com/ys1000/hook-runner
    tag: "latest"
velero:
  enabled: true
  image: registry.cn-shanghai.aliyuncs.com/ys1000/velero:v1.7.0
  plugins: registry.cn-shanghai.aliyuncs.com/ys1000/velero-plugin-for-aws:v1.3.0,registry.cn-shanghai.aliyuncs.com/ys1000/velero-plugin-for-csi:v0.2.0
```

第五步，使用helm本地安装YS1000。
```
# helm install qiming-operator qiming-operator-2.1.0.tgz --namespace qiming-migration --create-namespace -f qiming-values.yaml --set service.type=NodePort --set s3Config.provider=aws --set s3Config.name=minio --set s3Config.accessKey=minio --set s3Config.secretKey=minio123 --set s3Config.bucket=test --set s3Config.s3Url=http://139.198.27.211:31900
```

第六步，查看qiming-operator版本和pod运行情况，等待pod ready
```
# kubectl -n qiming-migration get pods
NAME                                                READY   STATUS    RESTARTS   AGE
mig-controller-default-5b4f996675-m86hw             1/1     Running   0          22s
qiming-operator-77c4cb9f76-jd2tq                    1/1     Running   0          35s
qiming-operator-velero-installer-6867d55f7d-przjh   1/1     Running   0          35s
ui-discovery-default-7cc4bb646-bd5dr                2/2     Running   0          22s

# kubectl -n qiming-backend get pods
NAME                      READY   STATUS    RESTARTS   AGE
restic-nxb4k              1/1     Running   0          48s
restic-vtjvf              1/1     Running   0          48s
velero-58d86bfd96-7qbmf   1/1     Running   0          48s

# helm list -A
NAME            NAMESPACE               REVISION        UPDATED                                 STATUS          CHART                   APP VERSION 
qiming-operator qiming-migration        1               2021-12-22 11:03:12.138661316 +0800 CST deployed        qiming-operator-2.1.0   2.1.0
```

第七步，安装成功后根据提示获取访问url和token，并登陆YS1000前端
```
2. After status is ready, get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace qiming-migration -o jsonpath="{.spec.ports[0].nodePort}" services ui-service-default )
  export NODE_IP=$(kubectl get nodes --namespace qiming-migration -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

3. Login web UI with the token by running these commands:
  export SECRET=$(kubectl -n qiming-migration get secret | (grep qiming-operator |grep -v helm || echo "$_") | awk '{print $1}')
  export TOKEN=$(kubectl -n qiming-migration describe secrets $SECRET |grep token: | awk '{print $2}')
  echo $TOKEN
```
