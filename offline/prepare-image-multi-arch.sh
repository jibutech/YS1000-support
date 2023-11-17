#!/bin/sh

if [ $# -ne 2 ];then
  echo "invalid paramters"
  echo "$0 <-d|-u|-e> <ys1000|app|s3tools|harbor|all>"
  echo "  first param:"
  echo "    -d: download images to local ./images only"
  echo "    -u: update images to new repo configured byenv variable: ${REPOSITRY_ID} "
  echo "    -e: do both download and then upload to new repo configured byenv variable: ${REPOSITRY_ID} "
  echo "  second param:"
  echo "    ys1000: only ys1000 images"
  echo "    app: only sample applications"
  echo "    s3tools: s3 related images"
  echo "    harbor: harbor installation images"
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
elif [ "$imageType" == "harbor" ];then
  echo "image type: harbor only"
else
  imageType="all"
  echo "image type: all for ys1000, s3tools, harbor and app samples"
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

        regctl image manifest --platform linux/arm64 $image
        if [ $? -ne 0 ];then
          echo "failed to get linux/arm64 bundle, exit..."
          exit 1
        fi

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

regectl=`which regctl`
if [ $? -ne 0 ];then
  echo "regctl must be installed and configured in \$PATH"
  exit 1
fi

if [ "$method" == "-d" ];then
  if [ "$imageType" == "all" ] || [ "$imageType" == "ys1000" ];then
    downloadImageFiles "${ys1000Images[@]}"
  fi

  if [ "$imageType" == "all" ] || [ "$imageType" == "s3tools" ];then
    downloadImageFiles "${s3gatewayImages[@]}"
  fi

  if [ "$imageType" == "all" ] || [ "$imageType" == "app" ];then
    downloadImageFiles "${appImages[@]}"
  fi

  if [ "$imageType" == "all" ] || [ "$imageType" == "harbor" ];then
    downloadImageFiles "${harborImages[@]}"
  fi
  
elif [ "$method" == "-u" ];then
  uploadImages
else
  echo "not support"
  exit 1
fi
