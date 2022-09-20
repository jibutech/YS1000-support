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
      output=$(docker load -i ./images/$file)
      if [ $? -ne 0 ];then
        echo "failed to docker load -i $image "
        exit 1
      fi
      image=$(echo $output | awk '{print $3}')
      if [ "$image" == "" ];then
        echo "failed to get image from $output"
        exit 1
      fi

      newImage=$(getNewImages ${image})
      docker tag $image $newImage
      if [ $? -ne 0 ];then
          echo "failed to docker tag $image to $newImage"
          exit 1
      else
          echo "docker tag $image to $newImage done!"
      fi

      docker push $newImage
      if [ $? -ne 0 ];then
          echo "failed to docker push $newImage"
          exit 1
      else
          echo "docker push $newImage done!"
      fi

  done
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
        echo $image
        docker pull $image
        if [ $? -ne 0 ];then
            echo "failed to docker pull $image "
            exit 1
        else
            echo "docker pull $image done!"
        fi

        imageName=$(echo $image | cut -d/ -f3)
        docker save $image -o ./images/$imageName
        if [ $? -ne 0 ];then
            echo "failed to docker save $image "
            exit 1
        else
            echo "docker save $image done!"
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

ys1000Repo=registry.cn-shanghai.aliyuncs.com/jibudata

originTag=v2.8.0
ys1000Images=(
    ${ys1000Repo}/qiming-operator:${originTag}
    ${ys1000Repo}/mig-ui:${originTag}
    ${ys1000Repo}/mig-discovery:${originTag}
    ${ys1000Repo}/mig-controller:${originTag}
    ${ys1000Repo}/velero-restic-restore-helper:v1.7.0
    ${ys1000Repo}/velero-installer:${originTag}
    ${ys1000Repo}/hook-runner:latest
    ${ys1000Repo}/hookrunner:${originTag}
    ${ys1000Repo}/cron:${originTag}
    ${ys1000Repo}/helm-tool:${originTag}
    ${ys1000Repo}/self-restore:${originTag}
    ${ys1000Repo}/amberapp:0.0.6
    ${ys1000Repo}/data-mover:${originTag}
    ${ys1000Repo}/webserver:${originTag}
    ${ys1000Repo}/dm-agent:${originTag}
    ${ys1000Repo}/restic-dm:${originTag}
    ${ys1000Repo}/velero:v1.7.0-jibu-39a9e6f-202207011049
    ${ys1000Repo}/velero-plugin-for-aws:v1.3.0
    ${ys1000Repo}/velero-plugin-for-csi:v0.2.0-jibu-2801dcd 
    ${ys1000Repo}/velero-plugin:${originTag}
    ${ys1000Repo}/mysql:8.0.29-debian-10-r23
    ${ys1000Repo}/ys1000-offline-installer:v2.8.0
    ${ys1000Repo}/log-collector:v2.7.0
)


s3gatewayImages=(
    registry.cn-shanghai.aliyuncs.com/ys1000/bitnami-shell:10-debian-10-r275 
    registry.cn-shanghai.aliyuncs.com/ys1000/minio-client:2021.12.10-debian-10-r1 
    registry.cn-shanghai.aliyuncs.com/ys1000/minio:2021.12.10-debian-10-r0)

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
    downloadImageFiles "${ingressImages[@]}"
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
  if [ "$imageType" == "all" ] || [ "$imageType" == "ys1000" ];then
    exportImages "${ys1000Images[@]}"
    exportImages "${s3gatewayImages[@]}"
    exportImages "${ingressImages[@]}"
  fi

  if [ "$imageType" == "all" ] || [ "$imageType" == "app" ];then
    exportImages "${wordpressImages[@]}"
    exportImages "${cronjobImages[@]}"
    exportImages "${daemonsetImages[@]}"
    exportImages "${kafkaImages[@]}"
    exportImages "${nginxImages[@]}"
  fi
fi
