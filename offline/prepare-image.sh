#!/bin/sh

if [ -z $REPOSITRY_ID ];then
    echo "need to set env REPOSITRY_ID, such as export REPOSITRY_ID=registry.cn-shanghai.aliyuncs.com/ys1000 "
    exit 1
fi


function getNewImages {
  image=$1
  newImage=$(echo $image | cut -d/ -f3)
  if [ "$newImage" == "" ];then
      echo "getNewImages failed to $image"
      exit 1
  fi

  echo ${REPOSITRY_ID}/${newImage}
}


function downloadImages {
    for image in "$@"
    do
        docker pull $image
        if [ $? -ne 0 ];then
            echo "failed to docker pull $image "
            exit 1
        else
            echo "docker pull $image done!"
        fi
    done
}

function retagImages {
    for image in "$@"
    do
        newImage=$(getNewImages ${image})
        docker tag $image $newImage
        if [ $? -ne 0 ];then
            echo "failed to docker tag $image to $newImage"
            exit 1
        else
            echo "docker tag $image to $newImage done!"
        fi
    done 
}

function pushImages {
    for image in "$@"
    do
        newImage=$(getNewImages ${image})
        docker push $newImage
        if [ $? -ne 0 ];then
            echo "failed to docker push $newImage"
            exit 1
        else
            echo "docker push $newImage done!"
        fi
    done
}

function exportImages {
    array=("$@")
    downloadImages "${array[@]}" 
    retagImages "${array[@]}"
    pushImages "${array[@]}"
}

ys1000Images=(registry.cn-shanghai.aliyuncs.com/ys1000/mig-ui:v2.1.0 registry.cn-shanghai.aliyuncs.com/ys1000/mig-discovery:v2.1.0 registry.cn-shanghai.aliyuncs.com/ys1000/mig-controller:v2.1.0  registry.cn-shanghai.aliyuncs.com/ys1000/velero-restic-restore-helper:v1.7.0  registry.cn-shanghai.aliyuncs.com/ys1000/velero-installer:v2.1.0 registry.cn-shanghai.aliyuncs.com/ys1000/hook-runner:latest registry.cn-shanghai.aliyuncs.com/ys1000/velero:v1.7.0 registry.cn-shanghai.aliyuncs.com/ys1000/qiming-operator:v2.1.0 registry.cn-shanghai.aliyuncs.com/ys1000/velero-plugin-for-aws:v1.3.0 registry.cn-shanghai.aliyuncs.com/ys1000/velero-plugin-for-csi:v0.2.0)


s3gatewayImages=(registry.cn-shanghai.aliyuncs.com/ys1000/bitnami-shell:10-debian-10-r275 registry.cn-shanghai.aliyuncs.com/ys1000/minio-client:2021.12.10-debian-10-r1 registry.cn-shanghai.aliyuncs.com/ys1000/minio:2021.12.10-debian-10-r0)

ingressImages=(registry.cn-shanghai.aliyuncs.com/ys1000/ingress-nginx-controller:v0.40.2 registry.cn-shanghai.aliyuncs.com/ys1000/kube-webhook-certgen:v1.3.0)

wordpressImages=(registry.cn-shanghai.aliyuncs.com/ys1000/mysql:5.6 registry.cn-shanghai.aliyuncs.com/ys1000/wordpress:4.8-apache registry.cn-shanghai.aliyuncs.com/ys1000/busybox:latest)

cronjobImages=(registry.cn-shanghai.aliyuncs.com/ys1000/busybox:latest)

daemonsetImages=(registry.cn-shanghai.aliyuncs.com/ys1000/fluentd:v2.5.2)


kafkaImages=(registry.cn-shanghai.aliyuncs.com/ys1000/kafka:2.8.1-debian-10-r57 registry.cn-shanghai.aliyuncs.com/ys1000/kubectl:1.19.16-debian-10-r25 registry.cn-shanghai.aliyuncs.com/ys1000/bitnami-shell:10-debian-10-r260 registry.cn-shanghai.aliyuncs.com/ys1000/kafka-exporter:1.4.2-debian-10-r67 registry.cn-shanghai.aliyuncs.com/ys1000/jmx-exporter:0.16.1-debian-10-r129)

nginxImages=(registry.cn-shanghai.aliyuncs.com/ys1000/nginx:latest registry.cn-shanghai.aliyuncs.com/ys1000/debian:latest)

exportImages "${ys1000Images[@]}"
exportImages "${s3gatewayImages[@]}"
exportImages "${ingressImages[@]}"

# disable test apps by default
#exportImages "${wordpressImages[@]}"
#exportImages "${cronjobImages[@]}"
#exportImages "${daemonsetImages[@]}"
#exportImages "${kafkaImages[@]}"
#exportImages "${nginxImages[@]}"


