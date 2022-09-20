# 银数多云数据管家2.7版使用说明书

## 目录结构

- [1. 银数多云数据管家典型用户场景介绍](#1-银数多云数据管家典型用户场景介绍)
    - [1.1 本地Kubernetes集群应用和数据的日常备份与恢复](#11-本地Kubernetes集群应用和数据的日常备份与恢复)
    - [1.2 在其它Kubernetes集群中恢复应用和数据](#12-在其它Kubernetes集群中恢复应用和数据)
    - [1.3 应用的跨云迁移](#13-应用的跨云迁移)
- [2. 运行环境与兼容性](#2-运行环境与兼容性)
- [3. 软件配置与授权](#3-软件配置与授权)
- [4. 配置集群与备份仓库](#4-配置集群与备份仓库)
    - [4.1 配置待保护Kubernetes集群](#41-配置待保护Kubernetes集群)
    - [4.2 配置备份仓库](#42-配置备份仓库)
    - [4.3 配置快照](#43-配置快照)
- [5. 备份设置](#5-备份设置)
    - [5.1 创建备份策略](#51-创建备份策略)
    - [5.2 创建备份任务](#52-创建备份任务)
    - [5.3 执行备份任务](#53-执行备份任务)
    - [5.4 查看备份作业](#54-查看备份作业)
    - [5.5 取消备份作业](#55-取消备份作业)
- [6. 恢复至本集群](#6-恢复至本集群)
    - [6.1 创建应用恢复任务](#61-创建应用恢复任务)
    - [6.2 执行应用恢复任务](#62-执行应用恢复任务)
    - [6.3 查看应用恢复作业](#63-查看应用恢复作业)
    - [6.4 取消应用恢复作业](#64-取消应用恢复作业)
- [7. 恢复至其它集群](#7-恢复至其它集群)
    - [7.1 创建、执行、查看应用恢复任务](#71-创建、执行、查看应用恢复任务)
    - [7.2 修改相应应用信息](#72-修改相应应用信息)
- [8. 跨集群迁移](#8-跨集群迁移)
    - [8.1 创建迁移任务](#81-创建迁移任务)
    - [8.2 执行增量迁移任务](#82-执行增量迁移任务)
    - [8.3 执行一键迁移任务](#83-执行一键迁移任务)
    - [8.4 查看迁移作业](#84-查看迁移作业)
    - [8.5 取消迁移作业](#85-取消迁移作业)
    - [8.6 修改相应应用信息](#86-修改相应应用信息)
    - [8.7 钩子程序](#87-钩子程序)
- [9. 配置作业报告](#9-配置作业报告)
- [10. YS1000的自备份与恢复](#10-YS1000的自备份与恢复)
- [11. 产品限制](#11-产品限制)
- [12. 故障与诊断](#12-故障与诊断)
    - [12.1 日志收集](#121-日志收集)
    - [12.2 常见问题](#122-常见问题)


## 1. 银数多云数据管家典型用户场景介绍

银数多云数据管家（YS1000）是一款创新的云原生软件产品，为企业提供核心业务在多云架构下的备份恢复、应用迁移及容灾保护服务，它可以适用于多个云原生的业务场景中。

### 1.1 本地Kubernetes集群应用和数据的日常备份与恢复

通过银数多云数据管家，用户可以设置策略将容器应用和数据进行自动备份，当遇到事故时，可以对容器应用和数据进行一键恢复。

备份示意图：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-backup.png)

恢复示意图：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-local-restore.png)

### 1.2 在其它Kubernetes集群中恢复应用和数据

用户测试环境中，常常希望能使用开发集群或生产集群中的应用和数据副本进行测试，通过银数多云数据管家，用户可以利用开发集群或生产集群中应用和数据的备份，在测试集群中恢复出同样的环境进行测试。

当生产集群遇到软硬件故障或站点故障时，通过银数多云数据管家，用户可以利用生产集群中应用和数据的备份，在灾备站点集群来恢复应用，以提高业务连续性。

跨集群恢复示意图：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-remote-restore.png)

### 1.3 应用的跨云迁移

通过银数多云数据管家，用户可以一键将容器应用从一个Kubernetes集群迁移至另外一个完全异构的Kubernetes集群，如生产集群到灾备集群的切换，或不同厂商、架构的Kubernetes集群间的应用迁移等。

迁移示意图（一）

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-migration1.png)

迁移示意图（二）

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-migration2.png)

## 2. 运行环境与兼容性

推荐使用Firefox访问银数多云数据管家2.6版控制台。

目前YS1000 2.6版支持管理的Kubernetes版本、对象存储以及主存储如下表所示：

| Kubernetes发行版   | S3对象存储                          | 云原生存储    | Snapshot CRD |
| ------------------ | ----------------------------------- | ------------- | ------------ |
| k8s社区版1.17-1.21 | S3兼容的对象存储（minio，qingstor） | NFS           | v1beta1      |
|                    |                                     | Rook Ceph 1.4-1.8 | v1           |

## 3. 软件配置与授权

|                  | 体验版 | 企业版       | 尊享版       |
| ---------------- | ------ | ------------ | ------------ |
| 集群节点数量     | 1-10   | 1-50         | 1-1000       |
| 最大管理集群数量 | 2      | 20           | 100          |
| 售后支持         | 无     | 24*7远程支持 | 24*7远程支持 |
| 是否需要授权     | 否     | 是           | 是           |

## 4. 配置集群与备份仓库

### 4.1 配置待保护Kubernetes集群

第一步，从左侧菜单栏中选择“集群信息”进入集群配置页面：


![](https://gitee.com/jibutech/tech-docs/raw/master/images/cluster-config-2.4.png)

第二步，点击“添加集群”按钮进入集群添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add-cluster-2.4.png)


“集群名称”请输入待保护Kubernetes集群名称。

“URL”请输入待保护Kubernetes集群的API服务器地址。

“账号令牌”栏，请创建一个具有 cluster admin 权限的 service account， 并获取对应的token，或者使用已有的token。以下是创建的命令：

```bash
kubectl create serviceaccount k8sadmin -n kube-system
kubectl create clusterrolebinding k8sadminrb --clusterrole=cluster-admin --serviceaccount=kube-system:k8sadmin
```

用下面命令拿到这个token：

```bash
kubectl -n kube-system describe secret $(sudo kubectl -n kube-system get secret | (grep k8sadmin || echo "$_") | awk '{print $1}') | grep token: | awk '{print $2}'
```

第三步，点击“保存”按钮，YS1000会自动对待保护Kubernetes集群进行连接测试，如果连接成功，在状态栏会显示“连接成功”。


如果需要修改集群的镜像源，可以勾选“替换镜像源”，并填入需要替换的url（但是路径和tag需要与原image保持一致），如果原image试docker默认缩写地址，则不做替换。

如果需要添加集群的网络限速，可以勾选“网速限制”，并填入限速速度和限速时段（当前版本仅支持每天一个时间段的限速）


### 4.2 配置备份仓库

银数多云数据管家支持兼容S3接口的对象存储作为数据备份仓库。

第一步，从左侧菜单栏中选择“数据备份仓库”进入数据备份仓库配置页面：


![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3-config-2.4.png)


第二步，点击“创建备份仓库”按钮进入备份仓库添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add-s3-beta.png)

选择备份仓库类型，输入数据备份仓库名称，S3存储空间名称，S3存储空间区域，访问密钥及访问密钥口令，若选择的备份仓库类型为S3，则还需要输入访问域名。

第三步，点击“提交”按钮，银数多云数据管家会自动对数据备份仓库进行访问测试，如果测试成功，在状态栏会显示“连接成功”。


### 4.3 配置快照

配置快照是为了支持用CSI快照方式来进行备份与恢复。下面以Ceph为例来描述如何配置快照。

第一步，创建Ceph的SnapshotClass，以下是一个snapshotclass.yaml的示例：

```yaml
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotClass
metadata:
 name: csi-rbdplugin-snapclass
 labels:
  velero.io/csi-volumesnapshot-class: "true"
driver: rook-ceph.rbd.csi.ceph.com
parameters:
 # Specify a string that identifies your cluster. Ceph CSI supports any
 # unique string. When Ceph CSI is deployed by Rook use the Rook namespace,
 # for example "rook-ceph".
 clusterID: rook-ceph
 csi.storage.k8s.io/snapshotter-secret-name: rook-csi-rbd-provisioner
 csi.storage.k8s.io/snapshotter-secret-namespace: rook-ceph
deletionPolicy: Retain 
```

**其中，SnapshotClass的`deletionPolicy`必须是`Retain`，并且加上velero需要的label (`velero.io/csi-volumesnapshot-class: "true"`)，这样后面在配置备份时候，会协调velero来产生并备份PV的快照。在YS1000 v2.5.0版本中，会自动检测snapshotclass中这两个参数是否存在和赋值，如果不一致则自动生成符合条件的新的snapshotclass。**

第二步，检查Storageclass和Volumesnapshotclass对应关系。

查看Storageclass的provisioner名字, 这里是 `rook-ceph.rbd.csi.ceph.com`

```bash
bash# kubectl get sc rook-ceph-block -oyaml |yq .provisioner
rook-ceph.rbd.csi.ceph.com
```

查看Volumesnapshotclass的driver名字, 这里是 `rook-ceph.rbd.csi.ceph.com`

```bash
bash# kubectl get volumesnapshotclasses csi-rbdplugin-snapclass -oyaml |yq .driver
rook-ceph.rbd.csi.ceph.com
```

如果Storageclass的provisioner名字和Volumesnapshotclass的driver名字相同(例如ceph), 则跳到第三步; 如果不同(例如华为云csi-disk)则需要在Volumesnapshotclass添加annotation (`velero.io/csi-volumesnapshot-class-provisioner`), 对应的值为storageclass的provisioner名字。例子如下：

```yaml
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotClass
metadata:
 name: csi-disk-snapclass
 annotations:
   velero.io/csi-volumesnapshot-class-provisioner: "everest-csi-provisioner"
 labels:
  velero.io/csi-volumesnapshot-class: "true"
driver: disk.csi.everest.io
parameters:
 ...
deletionPolicy: Retain 
```

第三步，配置Volumesnapshot CRD。

首先检查集群是否已经配置了Volumesnapshot CRD，如果已经配置，则跳过此步骤。

目前，银数多云数据管家支持的Snapshot CRD版本为v1beta1。

1. 获取external-snapshotter的代码仓库：

```bash
git clone https://github.com/kubernetes-csi/external-snapshotter.git
```

2. 进入external-snapshotter目录，切换到`release-4.1`分支

```bash
git checkout release-4.1
```

3.  执行以下命令来创建CRD：

```bash
kubectl create -f config/crd
```

4.  执行以下命令来创建snapshot controller：

```bash
kubectl create -f deploy/kubernetes/snapshot-controller/
```

## 5. 备份设置


从YS1000 v2.6.0版本开始，内置4个备份策略，用户也可以另外创建备份策略。

### 5.1 创建备份策略

从YS1000 2.4版本开始，支持选择备份资源类型，默认备份完整命名空间资源，也可以选择仅备份PVC数据卷或仅备份K8S资源。

在银数多云数据管家左侧菜单栏中选择“备份策略”进入备份策略页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-config-2.6.png)

第一步，点击“创建备份策略”按钮进入备份策略添加页面，从YS1000 2.6版本开始，支持更加灵活的定时频率设置。

创建一个默认类型资源的文件拷贝策略，指定在每天 0:40，9:40，13:40和19:40开始备份。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-file-2.6.png)

创建一个仅备份pvc数据卷的快照拷贝策略，指定在每星期一、三、五的10:15开始备份。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-snap-2.6.png)

创建一个仅备份k8s资源的策略，每隔3小时执行一次，指定每次在10分开始备份。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-k8s-2.6.png)


注意：若选择默认备份，则恢复时可恢复全部资源，或者选择仅恢复部分资源；
     若选择仅备份PVC数据卷，则恢复时只能对应选择仅恢复PVC数据卷；
     若选择仅备份K8S资源，则恢复时只能对应选择部分K8S资源.

备份方法除了仍支持基于存储快照的备份和基于文件拷贝的备份，还新增了存储快照备份+后台数据导出的高级模式。

如需使用快照备份+后台数据导出的方式：备份方法选择“快照拷贝”，“是否导出快照”选择“是”，默认选择立即导出全部快照。
如果需要选择导出其中某些快照，设置“是否立即导出全部快照”为“否”，选择需要导出的快照，默认选择立即导出所选快照。
如果需要指定快照导出的执行时间，设置“是否立即导出所选快照”为“否”，指定快照导出的执行时间。
则所选择的快照将在备份执行完成后在指定时间自动导出到备份仓库。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-exp1-2.6.png)

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-exp2-2.6.png)

第二步，填写完成所需策略参数后点击“保存”，可查看策略页面新增的策略。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-list-2.6.png)

### 5.2 创建备份任务

在银数多云数据管家左侧菜单栏中选择“集群应用备份”进入备份页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-config-2.6.png)

第一步，点击“创建应用备份任务”按钮进入备份任务添加页面。

用户需要输入备份任务的名称，选择待保护的集群，以及备份目标仓库。

备份方式支持按需备份和定时备份:

- 按需备份由用户按照需求手动点击“备份”来触发备份作业。

- 定时备份由系统按照用户指定的备份策略触发备份作业。

 当备份数据超过指定备份保留时长后，相关的备份数据将被系统自动删除。
 
从YS1000 v2.6.0版本开始，可以直接引用策略，也可以临时创建自定义策略，仅供该备份计划使用。

引用策略

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-create-snap1-2.6.png)

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-create-snap2-2.6.png)

创建自定义策略

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-create-temp-2.6.png)


第二步，点击“下一步”选择需要备份的命名空间。

用户可以通过“筛选”按钮对命名空间进行筛选，或者通过搜索栏搜索相关名称快速找到需要备份的命名空间。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-create-2-2.6.png)

第三步，点击“下一步”确认需要备份的持久卷。

系统会自动选择出用户指定命名空间中使用到的持久卷，用户可以进行确认。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-create-3-2.6.png)

第四步，点击“下一步”确认持久卷的备份方法。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-create-4-2.6.png)


第五步，点击“下一步”选择备份前保护数据库一致性（目前仅支持mysql和mongodb，后续开放postgresql），并勾选开启保护。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-create-5-2.6.png)

第六步，跳过钩子程序直接点击完成（从YS1000 2.2版本开始提供了数据一致性保护的默认钩子，但目前无法与自定义钩子程序同时使用，如需使用则需跳过数据一致性保护后创建）


![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-create-6-2.6.png)

点击“完成”按钮后，备份任务创建成功，系统会自动对备份任务进行验证。



### 5.3 执行备份任务

对于定时备份策略，系统会自动按照定时设定进行备份。同时，用户可以选择备份任务手动触发备份作业。

在备份页面中，选择对应备份任务的“<img src="https://gitee.com/jibutech/tech-docs/raw/master/images/backup-button-2.6.png" style="zoom:5%;" />”列，在操作中选择“备份”，即可触发备份作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-start-2.6.png)

点击“确定”按钮，备份作业即开始运行。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-confirm-2.6.png)


### 5.4 查看备份作业

在备份页面中，点击“备份任务”栏的链接，即可查看备份作业的执行情况。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-started-2.6.png)

备份任务成功后，可点击右侧“恢复”按钮进行恢复。

从YS1000 v2.6.0版本开始，新增任务监控页面，可以查看所有备份、恢复和迁移任务，并可查看备份资源详情，以及每个资源的yaml文件

![](https://gitee.com/jibutech/tech-docs/raw/master/images/jobmonitor-page-2.6.png)

从YS1000 v2.7.0版本开始，新增任务详情页面，可以查看每个备份、恢复任务的详细情况

详情页面有两个入口
1.点击备份任务右侧“详情”按钮
2.点击任务监控中的备份/恢复任务名称

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-1-2.7.png)

切换到资源列表

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-2-2.7.png)

点击某个资源查看yaml

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-3-2.7.png)

### 5.5 取消备份作业

备份任务进行时，可点击右侧“取消”按钮进行取消

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-cancel-1-2.7.png)

取消成功后，状态更新

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-cancel-2-2.7.png)

## 6. 恢复至本集群

从备份恢复应用至本集群一般在本地应用出现故障时使用（如命名空间被意外删除等），恢复往往无需进行应用资源本身相关的修改（如对外服务的域名和端口等）。


在成功的备份任务右侧点击“恢复”按钮进入恢复创建页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore-button-2.4.png)


### 6.1 创建应用恢复任务

第一步，点击“恢复”按钮进入应用恢复任务添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore1-2.5.png)


输入应用恢复任务名称，并选择目标恢复集群，此处选择本地kubernetes集群。

这里可以勾选对命名空间进行修改（**注意功能只适用于单个命名空间的备份**）。


第二步，点击下一步并选择恢复资源（注意不同备份任务对应的恢复资源限制不同，参见备份资源选择）

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore2-2.5.png)

第三步，点击“下一步”选择应用恢复的目标存储类型，以及是否移除节点限制。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore3-2.5.png)

第四步，点击“下一步”选择应用恢复后可以执行的钩子程序。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore4-2.5.png)


点击“完成”按钮后，恢复任务创建成功，系统会自动对恢复任务进行验证。

### 6.2 执行应用恢复任务


在应用恢复页面中，选择恢复任务列的链接，在相应恢复作业的"<img src="https://gitee.com/jibutech/tech-docs/raw/master/images/restore-activate-2.4.png" style="zoom:50%;" />"列操作中选择“激活”，即可触发任务恢复作业。


![](https://gitee.com/jibutech/tech-docs/raw/master/images/start-restore-beta.png)

### 6.3 查看应用恢复作业

在应用恢复页面中，点击恢复任务栏的链接，即可查看恢复作业的执行情况，也可以通过任务监控页面浏览概况。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore-status-beta.png)

从YS1000 v2.7.0版本开始，新增任务详情页面，可以查看每个备份、恢复任务的详细情况

详情页面有两个入口
1.点击恢复任务右侧“详情”按钮
2.点击任务监控中的备份/恢复任务名称

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restorejob-detail-1-2.7.png)

### 6.4 取消应用恢复作业

恢复任务进行时，可点击右侧“取消”按钮进行取消

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restorejob-cancel-1-2.7.png)

取消成功后，状态更新

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restorejob-cancel-2-2.7.png)

## 7. 恢复至其它集群

从备份恢复应用至其它集群一般在远程容灾场景、开发/测试场景、数据重用场景中使用，恢复完成后可能需要进行应用资源相关的修改（如对外服务的域名和端口等）。

同恢复至本地集群一样，在银数多云数据管家左侧菜单栏中选择“集群应用恢复”进入恢复页面。

### 7.1 创建、执行、查看应用恢复任务

对于创建、执行以及查看恢复任务的操作，可以参考5.1-5.3的内容，这里唯一的区别就是在选择恢复的集群时，选择的是跟备份集群不同的集群。

### 7.2 修改相应应用信息

在其它集群（如测试集群）恢复应用后，对于和原备份集群有冲突的资源需要进行相应的更改，然后才能在其它集群完全恢复应用。

如wordpress在新集群恢复后，仍旧会绑定备份集群中使用的域名，这时需要管理员将域名指向新集群IP，或者执行特定脚本来更改新域名。

## 8. 跨集群迁移

在银数多云数据管家左侧菜单栏中选择“跨集群应用迁移”进入应用迁移页面。


![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-config-2.4.png)


### 8.1 创建迁移任务

**【注意】在开始执行跨集群迁移任务前，要确认迁移的目标集群不存在资源冲突。**例如，如果迁移一个命名空间A到集群B，则要确认集群B不存在命名空间A。

 第一步，点击“创建迁移任务”按钮进入迁移任务添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-config-beta.png)

用户需要输入迁移任务名称，选择源端集群和目标端集群，以及备份仓库。

第二步，点击“下一步”选择需要迁移的命名空间。

用户通过多选框选择需要迁移的命名空间，目前银数多云数据管家2.2版支持同时迁移多个命名空间。

用户可以通过“筛选”按钮对命名空间进行筛选，或者通过搜索栏搜索相关名称快速找到需要备份的命名空间。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-sel-ns-beta.png)

第三步，点击“下一步”确认需要迁移的相关持久卷。

系统会自动选择出用户指定命名空间中使用到的持久卷，用户可以进行确认。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-sel-pv-beta.png)

第四步，点击“下一步”选择持久卷的目标集群存储类型，以及是否移除节点限制。

银数多云数据管家2.5版本支持文件系统拷贝的方式进行跨集群迁移。用户需要选择目标集群上应用恢复时需要使用的StorageClass。目标端集群使用的StorageClass和源端集群使用的StorageClass可以不同。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migration4-2.5.png)

### 8.2 执行增量迁移任务

从YS1000 2.7.0版本开始，支持增量迁移，即一个迁移计划创建后，可进行多次增量迁移，最后再进行一次一键迁移完成应用异地拉起
在应用迁移页面中，选择对应迁移计划的操作列，在操作中选择“增量迁移”，即可触发增量迁移作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-increment-2.7.png)


### 8.3 执行一键迁移任务

在应用迁移页面中，选择对应迁移计划的操作列，在操作中选择“一键迁移”，即可触发迁移作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-entire-2.7.png)

迁移过程默认会停掉源集群中选定命名空间内的应用，以保证数据一致性。

用户可以选择迁移过程中是否停止源集群中的应用运行。例如对于支持宕机一致性（crash-consistency）的应用，如果不希望在迁移过程中停止源集群中的应用运行，用户可以勾选此选项。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-confirm-beta.png)

点击“迁移”按钮，迁移作业即开始运行。

### 8.4 查看迁移作业

在迁移页面中，点击迁移任务栏的链接，即可查看迁移作业的执行情况，也可以通过任务监控页面浏览概况。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-started-beta.png)

### 8.5 取消迁移作业

迁移任务进行时，可点击右侧“取消”按钮进行取消

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-cancel-1-2.7.png)

取消成功后，状态更新

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-cancel-2-2.7.png)


### 8.6 修改相应应用信息

在目标端集群重新启动应用后，对于和源集群有冲突的资源需要进行相应的更改，然后才能在目标端完全恢复应用。如wordpress在目标端重启启动后，仍旧会绑定源端使用的域名，这时需要管理员将域名指向目标端集群IP，或者执行特定脚本来更改新域名。

### 8.7 钩子程序

钩子程序（Hook) 提供在备份，恢复以及迁移应用执行前后添加应用自定义逻辑的功能，满足不同应用的需求。
简单的自定义逻辑支持通过ansible playbook 脚本来实现，或者用户也可以根据应用需要开发自定义的钩子程序（容器镜像）。
钩子程序将会以 kubernetes 作业 (jobs.batch) 的形式在指定的备份，恢复以及迁移前后阶段执行。

常见的场景如下：

1. 应用数据一致性保证
   - 应用备份之前，通过自定义的 "prebackup" 钩子程序，调用应用的静默 (quiesce) 接口，暂停应用并将应用内存数据以及文件系统缓存刷入磁盘
   - 应用备份之后，通过自定义的 "postbackup" 钩子程序，调用应用的恢复 (unquiesce) 接口，恢复应用执行

2. 数据验证
   - 应用备份之后，通过自定义的 "postbackup" 钩子程序，验证数据完整性

3. 环境修改
   - 应用恢复到远程集群以后，需要对环境配置进行修改，比如通过 ingress 修改用户访问 web URL 地址

下面的例子以 wordpress 应用在跨集群迁移的场景下进行说明，wordpress 部署代码见 [wordpress example](https://github.com/jibutech/app-backup-hooks/tree/main/examples/wordpress)

- 迁移之前应用通过 https://wp-demo.jibudata.com:30165 访问 wordpress 
- 因业务需求，wordpress 需要迁移到远端目标集群，通过 https://blog.jibudata.com:30165 访问原 wordpress

1. 参考 [7.1 创建迁移任务](#71-创建迁移任务)，在创建迁移任务最后一步，如下图，点击 **添加钩子程序**

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add_hook_1.png)

2. 输入钩子程序名称，此处为 `postrestore-change-ingress-wp-url`

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add_hook_2.png)

3. 在 `Ansible playbook` 区域选择上次Ansible playbook 脚本或者直接将脚本内容复制到文本框中。 

此例的 ansible playbook 脚本为 [wp_migration_url_update.yaml](https://github.com/jibutech/app-backup-hooks/blob/main/examples/wordpress/wp_migration_url_update.yaml)。 

脚本根据wordpress 应用迁移要求，修改 mysql 数据库中的文章和站点的Web URL 地址，同时修改对外访问的ingress 地址。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add_hook_3.png)

4. 选择钩子程序执行的运行式环境并点击**创建** 按钮。

此例中，Ansible playbook 脚本在目标集群中执行，脚本示例采用在 wordpress mysql pod上直接运行命令进行数据库修改。

填入钩子程序作业运行所需的服务账户以及所在的命名空间，这里使用 `qiming-migration` （velero 安装的命名空间）以及 `velero` 服务账户来运行任务。
选择执行阶段为 "PostRestore".

**注意**: 

钩子程序运行操作需要确保指定的服务账户具有运行所需要的权限。

此例中 `velero` 服务账户具有 cluster admin 权限，因此可以通过 ansible 脚本登录到目标容器 (wordpress命名空间中的 mysql pod) 进行操作。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/2.2hook-4.png)


5. **创建**完成后，返回迁移任务向导页面，在钩子程序页面显示创建结果，之后点击 **完成** 按钮，参考 [7.2 执行迁移任务](#72-执行迁移任务) 执行迁移操作

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add_hook_5.png)

6. 完成迁移之后，访问新的 web URL 地址，可观察到 wordpress 页面以更新为新的域名地址

迁移之前：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/wp_before_mig.png)

迁移之后

![](https://gitee.com/jibutech/tech-docs/raw/master/images/wp_after_mig.png)


## 9. 配置作业报告

在银数多云数据管家左侧菜单栏中选择“配置”进入配置页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/config-2.6.png)

目前支持配置邮件和微信报告。

在创建邮件报告中，填写正确smtp地址和port，以及发送人邮箱地址。

如邮箱无需验证，则关闭验证按钮；如需验证，打开验证按钮，并填写正确授权码或者用户名密码。

在创建微信报告中，填写正确微信地址。

填写发送时间（目前仅支持每天指定一个时间点），打开启用，点击“保存”，便可在该时间点收到每天的作业执行报告。

邮件和微信相关参数配置可参考：

https://github.com/jibutech/docs/blob/main/email-configuration.md


## 10. YS1000的自备份与恢复


-   第一步，使用 helm upgrade 打开自备份功能，例如

    ```
    helm upgrade qiming-operator qiming/qiming-operator --namespace qiming-migration --set selfBackup.enabled=true
    ```
    
    其他升级参数设置参考：
    
    https://github.com/jibutech/helm-charts/blob/main/README.md#%E5%8D%87%E7%BA%A7

-   第二步，下载安装helmtool，并拷贝到可执行目录：

    ```
    docker cp $(docker create --rm registry.cn-shanghai.aliyuncs.com/jibudata/restore-job:release-2.7.0-latest):/usr/bin/helmtool /tmp/helmtool
    mv /tmp/helmtool /usr/local/bin/helmtool
    ```

-   第三步，在需要做恢复的集群上下载 

    https://github.com/jibutech/docs/blob/main/self-restore/self-restore-2.7.0.sh
    
    并按照脚本提示创建config文件，并填入自备份使用的s3信息
    
    执行该脚本，可自动安装对应的软件版本，并恢复所有备份资源



## 11. 产品限制


-   每个备份中最多包含 10个namespace，100个pod， 100个pvc

-   PVC的类型暂时不支持Host Path方式

-   如果Pod自带有emptyDir类型的Volume，备份会出错

    解决方法：对要备份的Pod加一个annotation：

    `kubectl -n <namespace> annotate pod/<podname> backup.velero.io/backup-volumes-excludes=<volumename>`

-   取消备份、恢复、迁移任务后，不会对已经生成的资源进行回退，需要手动检查环境并删除


## 12. 故障与诊断

### 12.1 日志收集

使用Helm安装YS1000的时可以指定YS1000的控制组件所使用的命名空间名字， 默认命令空间名为ys1000， YS1000的备份引擎安装在用户集群名为qiming-backend的命名空间内， 因此需要分别对控制组件和备份引擎进行日志收集。

## 

#### YS1000控制组件日志收集

1. 查询ys1000的serviceaccount， 更新server-log-collector.yaml文件中的serviceAccountName。

```
# server-log-collector.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: log-collector
  namespace: qiming-migration
  labels:
    app: log-collector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      serviceAccountName: qiming-operator
      containers:
      - name: log-collector
        image: registry.cn-shanghai.aliyuncs.com/jibudata/log-collector:v2.7.0
```

```
[root@gyj-dev ~]# kubectl -n ys1000 get sa
NAME                         SECRETS   AGE
default                      1         23d
qiming-operator-1634274895   1         10s

#  在server-log-collector.yaml搜索serviceAccountName并对应的"qiming-operator"替换为"qiming-operator-1634274895"

[root@gyj-dev ~]# grep serviceAccountName server-log-collector.yaml
      serviceAccountName: qiming-operator-1634274895
```

2. 部署 日志收集工具收集日志.

```
# 在ys1000命名空间内安装日志收集工具
[root@gyj-dev ~]# kubectl apply -f ./server-log-collector.yaml

# check log collector pod status
[root@gyj-dev ~]# kubectl -n ys1000 get pods
NAME                                                READY   STATUS    RESTARTS   AGE
log-collector-74c865f9-bb8xg                        1/1     Running   0          36m
cron-85b8fd5767-m2pfd                               1/1     Running   0          7d17h
mig-controller-default-784f64d4dc-fqrvz             1/1     Running   0          112m
mysql-0                                             1/1     Running   0          7d17h
ui-discovery-default-9d4ff6769-xwmjd                2/2     Running   0          5d21h
webserver-8d9b58776-4ck5b                           1/1     Running   0          5d21h

# 进入collector pod 
[root@gyj-dev ~]# k -n ys1000 exec -it log-collector-74c865f9-bb8xg -- sh

# 执行日志收集命令
(app-root) sh-4.4$ python /qiming/log-collector.py
(app-root) sh-4.4$ python /qiming/log-collector.py
Create logpath /tmp/qiming-migration-logs-1634224404.41/ys1000
Create logpath /tmp/qiming-migration-logs-1634224404.41/qiming-backend
Create log file for pod log-collector-74c865f9-bb8xg
Create log file for pod mig-controller-default-58ff75688c-g8rlj
Create log file for pod qiming-operator-94fcbbd57-6wg6c
Create log file for pod qiming-operator-velero-installer-78ddb79499-d8rbw
Create log file for pod ui-discovery-default-cdc8774bf-2rvpb
...
Collect configmap migration-cluster-config.yaml from namespace qiming-backend
Compress logs to /tmp/qiming-migration-logs-1634224404.41.tar

(app-root) sh-4.4$ ls -rlt /tmp/qiming-migration-logs-1634223960.63.tar
-rw-r--r-- 1 default root 15595520 Oct 14 15:06 /tmp/qiming-migration-logs-1634223960.63.tar

# 将打包后的日志拷贝到指定目录
[root@gyj-dev ~]# k -n ys1000 exec -it log-collector-74c865f9-bb8xg -- sh ^C
[root@gyj-dev ~]# kubectl cp ys1000/log-collector-74c865f9-bb8xg:/tmp/qiming-migration-logs-1634224404.41.tar /tmp/qiming-migration-logs-1634224404.41.tar
...
[root@gyj-dev ~]# ls -rlt /tmp/qiming-migration-logs-1634224404.41.tar
-rw-r--r-- 1 root root 15626240 10月 14 23:14 /tmp/qiming-migration-logs-1634224404.41.tar
```

## 

#### YS1000备份引擎日志收集

1. 下载文件client-log-collector.yaml

```
# client-log-collector.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: log-collector
  namespace: qiming-backend
  labels:
    app: log-collector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      serviceAccountName: velero
      containers:
      - name: log-collector
        image: registry.cn-shanghai.aliyuncs.com/jibudata/log-collector:v2.7.0
```

2. 部署日志收集工具并收集日志

```
# 安装日志收集工具
[root@gyj-dev ~]# kubectl apply -f ./client-log-collector.yaml

# 查看对应pod状态
[root@gyj-dev ~]#  kubectl -n qiming-backend get pods
NAME                                             READY   STATUS    RESTARTS   AGE
log-collector-76766456cc-hxnw5                   1/1     Running   0          35m
minio-7496b65c8-zxmqr                            1/1     Running   0          11h
amberapp-controller-manager-76d8fb4998-d8ndx     1/1     Running   0          12m
data-mover-controller-manager-5f6765fc9d-qmxwq   1/1     Running   0          12m
restic-hn5nw                                     1/1     Running   0          12m
velero-5586df6449-2w2nw                          1/1     Running   0          12m
velero-installer-76f989f69b-xzfm8                1/1     Running   0          13m

# 进入collector pod 
[root@gyj-dev ~]# k -n qiming-backend exec -it log-collector-76766456cc-hxnw5 -- sh

# 执行日志收集命令
(app-root) sh-4.4$ python /qiming/log-collector.py
Create logpath /tmp/qiming-migration-logs-1634223920.81/ys1000
Create logpath /tmp/qiming-migration-logs-1634223920.81/qiming-backend
Create log file for pod log-collector-74c865f9-bb8xg
Create log file for pod mig-controller-default-58ff75688c-g8rlj
Create log file for pod qiming-operator-94fcbbd57-6wg6c
Create log file for pod qiming-operator-velero-installer-78ddb79499-d8rbw
Create log file for pod ui-discovery-default-cdc8774bf-2rvpb
Create log file for pod log-collector-76766456cc-hxnw5
Create log file for pod minio-7496b65c8-zxmqr
...
Collect configmap migration-cluster-config.yaml from namespace ys1000
Collect configmap ui-configmap.yaml from namespace ys1000
Create logpath /tmp/qiming-migration-logs-1634223960.63/qiming-backend/configmap
Collect configmap migration-cluster-config.yaml from namespace qiming-backend
Compress logs to /tmp/qiming-migration-logs-1634223960.63.tar

(app-root) sh-4.4$ ls -rlt /tmp/qiming-migration-logs-1634223960.63.tar
-rw-r--r-- 1 default root 15595520 Oct 14 15:06 /tmp/qiming-migration-logs-1634223960.63.tar

# 将打包后的日志拷贝到指定目录
[root@gyj-dev ~]# kubectl cp qiming-backend/log-collector-76766456cc-hxnw5:/tmp/qiming-migration-logs-1634223960.63.tar /tmp/qiming-migration-logs-1634223960.63.tar
...
[root@gyj-dev ~]# ls -rlth /tmp/qiming-migration-logs-1634223960.63.tar
-rw-r--r-- 1 root root 15M 10月 14 23:11 /tmp/qiming-migration-logs-1634223960.63.tar
```

### 12.2 常见问题


- 快照备份不工作  
    可能原因：快照的SnapshotClass没配好，比如没有加所需要的label。  
    解决方法：请参考3.4节的“配置快照”，把相应的配置做好。
- 快照恢复失败  
    可能原因：快照的SnapshotClass的`deletionPolicy`不是`Retain`。  
    解决方法：用`kubectl`查看相应的`volumesnapshotcontents` CR，看`deletionPolicy`是不是`Retain`，如果不是，请参考3.4节的“配置快照”，并修改SnapshotClass的yaml文件，重新apply。
- 备份/恢复/迁移任务卡在50%左右一直不动  
    可能原因：当前集群前面有备份/恢复一直完成不了，卡在Velero的队列中。  
    解决方法：查看是否有一个备份/恢复一直在进行，等前一个备份完成，或者超时（现在大约要4小时）后，当前这个任务就会开始。如果不想等，可以重启Velero的Pod来观察问题是否解决。
- 恢复很慢，花了比预期多很多的时间  
    可能原因：如果是异地恢复，可以去查看恢复的命名空间，看Pod是不是Image Pull失败，或者有什么异常情况，导致Pod起来太慢。 
- 部署到k8s集群时，velero不能正常运行，并且报`unexpected directory structure for host-pods volume ...`的错误    
    原因：这是由于k8s在安装时，没有使用标准的`/var/lib/kubelet/pods/`的目录格式。     
    解决方法：执行`mount -l | grep kubelet`，找到集群实际的Pod的路径，例如`/var/k8s/kubelet/pods/`，然后执行：
    ```bash
    kubectl patch ds/restic --namespace qiming-migration --type json -p  '[{"op":"replace","path":"/spec/template/spec/volumes/0/hostPath","value": { "path": "/var/k8s/kubelet/pods"}}]'
    ```
- 备份一个k8s版本 >= 1.21 集群上的应用，再恢复到一个 k8s版本 <= 1.20 的集群上后，应用中pod无法正常running的问题，参考：

  https://velero.cn/d/37-k8s-121-beta-feature-boundserviceaccounttokenvelerorestic
