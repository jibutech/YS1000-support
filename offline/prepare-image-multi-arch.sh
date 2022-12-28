#!/bin/sh

if [ $# -ne 2 ];then
  echo "invalid paramters"
  echo "$0 <-d|-u|-e> <ys1000|app|all>"
  echo "  first param:"
  echo "    -d: download images to local ./images only"
  echo "    -u: update images to new repo configured byenv variable: ${REPOSITRY_ID} "
  echo "    -e: do both download and then upload to new repo configured byenv variable: ${REPOSITRY_ID} "
  echo "  second param:"
  echo "    ys1000: only ys1000 images"
  echo "    app: only test applications"
  echo "    all: both ys1000 and test apps"
  exit 1
fi

method=$1
if [ "$method" != "-d" ];then
  if [ -z $REPOSITRY_ID ];then
    echo "need to set env REPOSITRY_ID, such as export REPOSITRY_ID=registry.cn-shanghai.aliyuncs.com/ys1000 "
    exit 1
  fi

  if [ "$method" != "-u" ];then
    method="-e"
    echo "do image download & upload to new repo ${REPOSITRY_ID} "
  else
    echo "do image upload only from ./images directory to new repo ${REPOSITRY_ID}"
  fi
else
  echo "do image download only to local ./images directory"
fi

imageType=$2
if [ "$imageType" == "ys1000" ];then
  echo "image type: ys1000 only"
elif [ "$imageType" == "app" ];then
  echo "image type: app only"
else
  imageType="all"
  echo "image type: all for both ys1000 and app"
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

function uploadImages {
  images=$(ls ./images)
  if [ $? -ne 0 ];then
    echo "failed to 'ls ./images'"
    exit 1
  fi

  for file in $images
  do
      newImage=${REPOSITRY_ID}/$file
      echo "import $newImage "

      regctl image import $newImage ./images/$file
      if [ $? -ne 0 ];then
          echo "failed to regctl image import $newImage"
          exit 1
      else
          echo "regctl image import $newImage done!"
      fi

  done
  
  echo "--------"
  echo "all images are uploaded successfully"
}

function downloadImageFiles {
    if [ ! -d ./images ];then
        mkdir -p ./images
        if [ $? -ne 0 ];then
            echo "failed to create images dir"
            exit 1
        fi
    fi

    for image in "$@"
    do
        echo "start to export $image "

        imageName=$(echo $image | cut -d/ -f3)
        regctl image export $image > ./images/$imageName
        if [ $? -ne 0 ];then
            echo "failed to regctl image export $image "
            exit 1
        else
            echo "regctl image export $image done!"
        fi
    done

    echo "--------"
    echo "all images are downloaded successfully"
}

ys1000Repo=registry.cn-shanghai.aliyuncs.com/jibutech

originTag=2.10.3
ys1000Images=(
    ${ys1000Repo}/qiming-operator:${originTag}
    ${ys1000Repo}/webserver:${originTag}
    ${ys1000Repo}/hookrunner:${originTag}
    ${ys1000Repo}/agent-operator:${originTag}
    ${ys1000Repo}/velero:v1.7.0-jibu-dev-146eb2ff-20221122233612
    ${ys1000Repo}/velero-restic-restore-helper:v1.7.0
    ${ys1000Repo}/velero-plugin-for-aws:v1.3.0
    ${ys1000Repo}/velero-plugin-for-csi:v0.2.0-jibu-b99d08e-20221122124825
    ${ys1000Repo}/velero-plugin:${originTag}
    ${ys1000Repo}/data-mover:${originTag}
    ${ys1000Repo}/data-verify:${originTag}
    ${ys1000Repo}/amberapp:0.0.8
    ${ys1000Repo}/dm-agent:${originTag}
    ${ys1000Repo}/restic-dm:${originTag}
    ${ys1000Repo}/mig-ui:${originTag}
    ${ys1000Repo}/mig-discovery:${originTag}
    ${ys1000Repo}/mig-controller:${originTag}
    ${ys1000Repo}/cron:${originTag}
    ${ys1000Repo}/stub:${originTag}
    ${ys1000Repo}/hook-runner:latest
    ${ys1000Repo}/helm-tool:${originTag}
    ${ys1000Repo}/self-restore:${originTag}
    ${ys1000Repo}/mysql:8.0.29
    ${ys1000Repo}/apiserver:v0.6.0-alpha.0
    ${ys1000Repo}/clustersynchro-manager:v0.6.0-alpha.0
    ${ys1000Repo}/controller-manager:v0.6.0-alpha.0
)


s3gatewayImages=(
    registry.cn-shanghai.aliyuncs.com/jibutech/nfs-subdir-external-provisioner:v4.0.2
    registry.cn-shanghai.aliyuncs.com/jibutech/bitnami-shell:2022.12.21-debian-11
    registry.cn-shanghai.aliyuncs.com/jibutech/minio-client:2021.12.10-debian-11-r0
    registry.cn-shanghai.aliyuncs.com/jibutech/minio:2021.12.10-debian-11-r0
)

ingressImages=(registry.cn-shanghai.aliyuncs.com/ys1000/ingress-nginx-controller:v0.40.2 registry.cn-shanghai.aliyuncs.com/ys1000/kube-webhook-certgen:v1.3.0)

wordpressImages=(registry.cn-shanghai.aliyuncs.com/ys1000/mysql:5.6 registry.cn-shanghai.aliyuncs.com/ys1000/wordpress:4.8-apache registry.cn-shanghai.aliyuncs.com/ys1000/busybox:latest)

cronjobImages=(registry.cn-shanghai.aliyuncs.com/ys1000/busybox:latest)

daemonsetImages=(registry.cn-shanghai.aliyuncs.com/ys1000/fluentd:v2.5.2)


kafkaImages=(registry.cn-shanghai.aliyuncs.com/ys1000/kafka:2.8.1-debian-10-r57 registry.cn-shanghai.aliyuncs.com/ys1000/kubectl:1.19.16-debian-10-r25 registry.cn-shanghai.aliyuncs.com/ys1000/bitnami-shell:10-debian-10-r260 registry.cn-shanghai.aliyuncs.com/ys1000/kafka-exporter:1.4.2-debian-10-r67 registry.cn-shanghai.aliyuncs.com/ys1000/jmx-exporter:0.16.1-debian-10-r129 registry.cn-shanghai.aliyuncs.com/ys1000/zookeeper:3.7.0-debian-10-r188)

nginxImages=(registry.cn-shanghai.aliyuncs.com/ys1000/nginx:latest registry.cn-shanghai.aliyuncs.com/ys1000/debian:latest)

if [ "$method" == "-d" ];then
  if [ "$imageType" == "all" ] || [ "$imageType" == "ys1000" ];then
    downloadImageFiles "${ys1000Images[@]}"
    downloadImageFiles "${s3gatewayImages[@]}"
    #downloadImageFiles "${ingressImages[@]}"
  fi

  if [ "$imageType" == "all" ] || [ "$imageType" == "app" ];then
    downloadImageFiles "${wordpressImages[@]}"
    downloadImageFiles "${cronjobImages[@]}"
    downloadImageFiles "${daemonsetImages[@]}"
    downloadImageFiles "${kafkaImages[@]}"
    downloadImageFiles "${nginxImages[@]}"
  fi
  
elif [ "$method" == "-u" ];then
  uploadImages
else
  echo "not support"
  exit 1
fi
