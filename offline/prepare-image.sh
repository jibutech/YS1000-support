#!/bin/sh

set -e
set -o pipefail

if [ $# -ne 2 ];then
  echo "invalid paramters"
  echo "$0 <-d|-u|-e> <ys1000|app|s3tool|all>"
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
elif [ "$imageType" == "s3tools" ];then
  echo "image type: s3tools only"
else
  imageType="all"
  echo "image type: all for ys1000, s3tools and app samples"
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

script_dir=$(dirname $( dirname -- "$0"; ))
if [ ! -d "$script_dir" ];then
  echo "can't find script dir, abort..."
  exit 1
fi

image_conf="$script_dir/images.config"
if [ ! -f "$image_conf" ];then
  echo "can't find image config file, abort..."
  exit 1
fi

source $image_conf

if [ "$method" == "-d" ];then
  if [ "$imageType" == "all" ] || [ "$imageType" == "ys1000" ];then
    downloadImageFiles "${ys1000Images[@]}"
  fi

  if [ "$imageType" == "all" ] || [ "$imageType" == "s3tools" ];then
    downloadImageFiles "${s3gatewayImages[@]}"
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
  fi

  if [ "$imageType" == "all" ] || [ "$imageType" == "s3tools" ];then
    exportImages "${s3gatewayImages[@]}"
  fi

  if [ "$imageType" == "all" ] || [ "$imageType" == "app" ];then
    exportImages "${wordpressImages[@]}"
    exportImages "${cronjobImages[@]}"
    exportImages "${daemonsetImages[@]}"
    exportImages "${kafkaImages[@]}"
    exportImages "${nginxImages[@]}"
  fi
fi
