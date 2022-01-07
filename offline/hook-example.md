1. deploy a wordpress example in source cluster (cd tmp/wordpress-example-nfs)
[root@dce-10-31-203-81 wordpress-example-nfs]# ./install.sh 
namespace/wordpress created
service/wordpress-mysql created
persistentvolumeclaim/mysql-pv-claim created
deployment.apps/wordpress-mysql created
service/wordpress created
persistentvolumeclaim/wp-pv-claim created
deployment.apps/wordpress created
ingress.networking.k8s.io/wordpress-ingress created

[root@dce-10-31-203-81 wordpress-example-nfs]# kubectl get pods -n wordpress-1
NAME                               READY   STATUS    RESTARTS   AGE
wordpress-568f9f5cbb-rrch8         1/1     Running   0          93m
wordpress-mysql-647468759b-lnk8c   1/1     Running   0          93m

2.check there is no table in database "wordpress"
[root@dce-10-31-203-81 ~]# kubectl -n wordpress-1 exec -it wordpress-mysql-647468759b-lnk8c bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl kubectl exec [POD] -- [COMMAND] instead.
root@wordpress-mysql-647468759b-lnk8c:/# mysql -D wordpress -u root -p
Enter password: passw0rd
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2329
Server version: 5.6.51 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show tables;
Empty set (0.00 sec)

3.login ys1000 and create a migration, and add hook in last step

4.give a name and upload the yaml file wp_migration_hook.yaml

content of "wp_migration_hook.yaml":
---
- hosts: localhost
  gather_facts: false
  connection: local

  collections:
    - community.kubernetes

  tasks:
    - name: Ensure the wordpress Namespace exists.
      k8s:
        api_version: v1
        kind: Namespace
        name: wordpress
        state: present

    - name: Search for wordpress mysql
      community.kubernetes.k8s_info:
        namespace: wordpress
        kind: Pod
        label_selectors:
          - app = wordpress
          - tier = mysql
      register: wordpress_mysql
    
    - name: search & define pod name
      set_fact:
        pod_name: "{{ wordpress_mysql | json_query('resources[0].metadata.name') }}"

    - name: Display wordpress mysql details
      debug:
        msg: "{{ pod_name }}"
    
    - fail: msg="can not get mysql pod_name, failed"
      when: pod_name is undefined

    - name: create new table in wordpress database
      community.kubernetes.k8s_exec:
        namespace: wordpress-1
        pod: "{{ pod_name }}"
        command: mysql -u root -ppassw0rd -D wordpress -e "create table hook_test(id int(2))"
      register: command_status
      ignore_errors: True

5.select "目标k8s集群"，use service account “velero“ in ”qiming-backend“, and choose "PostRestore", then finish the hook and migration
6.click "一键迁移", after success, ssh to target cluster and check if there is a new table "hook_test" in wordpress
mysql> show tables;
+---------------------+
| Tables_in_wordpress |
+---------------------+
| hook_test           |
+---------------------+
1 row in set (0.00 sec)
