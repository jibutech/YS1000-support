#  银数多云数据管家2.5微信邮件报告配置

## 目录

- [1. 配置邮件配置邮件(授权码)](#1-配置邮件配置邮件(授权码))
    - [1.1 获取授权码](#11-获取授权码)
    - [1.2 使用授权码配置邮件报告](#12-使用授权码配置邮件报告)
    - [1.3 查看邮件报告内容](#13-查看邮件报告内容)
- [2. 配置邮件(用户名、密码)](#2-配置邮件(用户名、密码))
    - [2.1 使用用户名密码配置邮件报告](#21-使用用户名密码配置邮件报告)
- [3. 配置微信](#3-配置微信)
    - [3.1 开启企业微信地址](#31-开启企业微信地址)
    - [3.2 使用微信地址配置微信报告](#32-使用微信地址配置微信报告)
    - [3.3 查看微信报告内容](#33-查看微信报告内容)


## 1. 配置邮件(授权码)

以网易邮箱、QQ邮箱为例

注：网易邮箱与QQ邮箱不支持账号密码的方式

### 1.1 获取授权码

参考以下步骤开启客户端协议，获取授权码，以网易邮箱举例

（一）、登录网页版邮箱（https://email.163.com/) 进入邮箱首页

（二）、点击上方设置，选择POP/SMTP/IMAP选项。

![image](https://user-images.githubusercontent.com/97142288/167243765-230d1486-d954-4ddb-ab16-f4c9e9ec081a.png)

（三）、在客户端协议界面，选择开启对应的协议，IMAP或者POP3分别为不同的收信协议，您可以选择只开启需要的收信协议，比如IMAP，推荐使用IMAP协议来收发邮件，它可以和网页版完全同步。

![image](https://user-images.githubusercontent.com/97142288/167243795-97dac4df-2fd7-4021-8e0f-9fd89b515e8c.png)

（四）、在新弹出的弹窗中，点击继续开启，扫码页面您可以选择扫码发送短信，或者点击下方“手动发送短信”。（如果发送5分钟后系统依旧提示未收到短信，请联系移动运营商核实短信发送情况。）

![image](https://user-images.githubusercontent.com/97142288/167243830-b0d0aa51-9732-4899-bf97-ca757fbd8316.png)

![image](https://user-images.githubusercontent.com/97142288/167243833-37d93f8d-5abb-4115-a63f-5e08a1f26188.png)

（五）、点击我已发送后，如果系统检测到用户成功发送短信，则会提示您的客户端授权码（自动生成一串（16位字母组合）唯一随机授权密码），为了最大程度保证用户授权密码使用安全，一个授权码在开启后网页上只出现一次，但是一个授权码可以同时设置多个客户端。

您可以选择开启时记录该授权码在其他地方，或者需要设置额外的客户端时候，再次新增授权码使用，最多同时存在5个授权码

![image](https://user-images.githubusercontent.com/97142288/167243881-15d528f6-f047-4640-beaa-81eda21d6817.png)

### 1.2 使用授权码配置邮件报告

（一）、输入SMTP地址，port，发送人邮件地址

![image](https://user-images.githubusercontent.com/97142288/167244122-0a2cb771-d61f-4b44-97c4-1c76d66e5549.png)

(二)、勾选验证，输入授权码

![image](https://user-images.githubusercontent.com/97142288/167244131-fbeadbb4-08d9-4e68-bb6b-ba104db82f85.png)

![image](https://user-images.githubusercontent.com/97142288/167244141-5cfd5270-5f11-4bfc-a5c4-8d67aa71ac1a.png)

（三）、输入接收人邮件地址，选择报告发送时间（选择右侧 + 可添加多条接收人邮件地址）

![image](https://user-images.githubusercontent.com/97142288/167244233-fc63077f-5b1b-4a97-bc79-4ec224a16862.png)

![image](https://user-images.githubusercontent.com/97142288/167244251-dc8a3b6d-d196-4112-85a8-b31ab5bba748.png)

（四）、勾选启用和连接加密按键，点击保存

![image](https://user-images.githubusercontent.com/97142288/167244273-350df68d-b6ae-440e-b5fd-5ee9f2df0cc7.png)

### 1.3 查看邮件报告内容

ys1000邮件报告，以发送时间为准的过去24小时内的系统报告                                      

job的总览：success、failed、warning、running、queued、total的数量       

失败会显示具体的任务类型、名称、集群、ns、开始和结束的和时间、报错的信息 ，会显示无关的集群和无关的存储仓库   

警告信息：（前端warning信息、显示为N/A）        

长时间任务：显示任务类型，任务名称，集群，namespace，开始结束时间，警告信息       

pvc超出限制：集群，namespace，pvc名称，快照总数量，快照限制，计划名称（快照的计数/快照限制数量）    

所有任务：任务名称，任务名称，任务所使用的集群，namespace，开始结束时间，和任务的状态（完成/失败），系统的警告或失败信息，如没有，则显示“-”，显示所有的集群和存储仓库 

![image](https://user-images.githubusercontent.com/97142288/167244328-ddf07ab2-0f2e-4587-afd0-827e1d046e46.png)

![image](https://user-images.githubusercontent.com/97142288/167244342-e06d5e81-07bc-4918-97c5-b74d6c601606.png)

![image](https://user-images.githubusercontent.com/97142288/167244364-36fe7ed9-54ed-4147-a885-05d0b697c361.png)

![image](https://user-images.githubusercontent.com/97142288/167244365-e743d9c6-dd80-4129-8416-850199da8ea9.png)

## 2. 配置邮件(用户名、密码)

以outlook邮箱举例

注：同时使用用户名密码和授权码时，默认为用户名密码的配置

### 2.1 使用用户名密码配置邮件报告

（一）、输入SMTP地址，port，发送人邮件地址

![image](https://user-images.githubusercontent.com/97142288/167244122-0a2cb771-d61f-4b44-97c4-1c76d66e5549.png)

(二)、勾选验证，输入用户名密码

![image](https://user-images.githubusercontent.com/97142288/167244131-fbeadbb4-08d9-4e68-bb6b-ba104db82f85.png)

![image](https://user-images.githubusercontent.com/97142288/167245302-cd92e4a9-291c-4166-a052-5dbf18b45058.png)

（三）、输入接收人邮件地址，选择报告发送时间（选择右侧 + 可添加多条接收人邮件地址）

![image](https://user-images.githubusercontent.com/97142288/167244233-fc63077f-5b1b-4a97-bc79-4ec224a16862.png)

![image](https://user-images.githubusercontent.com/97142288/167244251-dc8a3b6d-d196-4112-85a8-b31ab5bba748.png)

（四）、勾选启用和连接加密按键，点击保存

![image](https://user-images.githubusercontent.com/97142288/167244273-350df68d-b6ae-440e-b5fd-5ee9f2df0cc7.png)

## 3. 配置微信

注：微信地址只能在企业微信群聊中使用

### 3.1 开启企业微信地址

请参考以下步骤开启企业微信地址

（一）、创建企业微信群聊，点击右上角，进入设置页面，选择群机器人、

![图片1](https://user-images.githubusercontent.com/97142288/167245904-dd2020d0-a4a0-486b-b7c5-9d5c18488bc7.png)

（二）、点击右上角添加

![图片2](https://user-images.githubusercontent.com/97142288/167245976-6eb903f2-3de7-49db-9d15-3345eedc4421.png)

（三）、点击添加机器人

![图片5](https://user-images.githubusercontent.com/97142288/167246078-aa24e7a2-19bf-4019-9713-94811a9800df.png)

（四）、设置机器人名称，点击添加

![图片3](https://user-images.githubusercontent.com/97142288/167246264-b595327d-1b14-46ce-9d64-99b29529b0b9.png)

（五）、添加完成，Webhook地址为微信报告的微信地址

![图片4](https://user-images.githubusercontent.com/97142288/167246257-aef3f771-48a1-49fc-bc50-863e4e6ded43.png)

### 3.2 使用微信地址配置微信报告

注：微信报告不能单独发送，在发送邮件报告时可添加微信报告

（一）、输入微信报告地址

![Snipaste_2022-05-07_16-37-28](https://user-images.githubusercontent.com/97142288/167246460-9d4c5f6b-8cfb-4f5d-9b4d-a7cbf351c751.png)


（二）、设置报告发送时间、点击启用、连接加密，点击保存

![image](https://user-images.githubusercontent.com/97142288/167246468-218a816c-a347-43c3-8a35-a1a5129b045b.png)

### 3.3 查看微信报告内容

ys1000微信报告，以发送时间为准的过去24小时内的系统报告

摘要信息：备份任务数量，失败数量

失败信息：备份任务，集群连接，存储连接

异常信息：超过一小时的备份任务

备份任务：完成数量，迁移任务：完成数量，恢复任务：完成数量，集群数量：连接数量，存储连接：存储连接数量

![IMG_0165](https://user-images.githubusercontent.com/97142288/167246814-00b39226-d63b-4612-addf-3e561ef89609.PNG)
