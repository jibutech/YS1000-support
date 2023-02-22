#!/bin/bash -e

#
# Copyright (C) 2022 Jibu Tech - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

# How to use this script?
# 1. Create a file called `config` in the same directory of this script and input the following envs:
# S3_URL=xxx
# S3_BUCKET=xxx
# S3_REGION=xxx
# S3_AK=xxx
# S3_SK=xxx
# S3_INSECURE=true
# 2. Download `helmtool` and put it to an executable path, like：
#    docker cp $(docker create --rm registry.cn-shanghai.aliyuncs.com/jibutech/restore-job:release-3.0.0-latest):/usr/bin/helmtool /tmp/helmtool
#    mv /tmp/helmtool /usr/local/bin/helmtool
# 3. Setup `kubectl` and `helm` if not
# 4. Run this script ./self-restore-x.x.x.sh


OS=$(uname)
CURRENT_PATH=$(dirname "$BASH_SOURCE")
ENV_PATH="${CURRENT_PATH}/config"

if [ -f "${ENV_PATH}" ]; then
  echo "Loading envs in ${ENV_PATH}"
  if [ "${OS}" = 'Linux' ]; then
    export $(grep -v '^#' "${ENV_PATH}" | xargs -d '\n')
  elif [ "${OS}" = 'Darwin' ]; then
    export $(grep -v '^#' "${ENV_PATH}" | xargs -0)
  else
    echo "Unsupported OS, only Linux and Mac are allowed"
    exit 1
  fi
fi

MANDATORY_ENVS="S3_URL S3_BUCKET S3_REGION S3_AK S3_SK S3_INSECURE"
for envi in ${MANDATORY_ENVS}; do
  if [ "${!envi}" == "" ]; then
    echo "Error - Env $envi is mandatory for the script, you need to export it before running this script or define it in file config."
    exit 1
  fi
done

RANDOM_SUFFIX=$(echo $RANDOM | md5sum | head -c 10)

mkdir /tmp/"${RANDOM_SUFFIX}"

echo "Pulling chart from s3"
helmtool pull --access-key "${S3_AK}" --secret-key "${S3_SK}" \
    --region "${S3_REGION}" --bucket "${S3_BUCKET}" \
    --url "${S3_URL}" --insecure="${S3_INSECURE}" \
    -d /tmp/"${RANDOM_SUFFIX}" --untar

CHART=/tmp/"${RANDOM_SUFFIX}"/ys1000

echo "Start restoring"
set -x
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo update bitnami
# helm dependency build "${CHART}"
helm install "restore-$RANDOM_SUFFIX" "${CHART}" \
    --namespace "restore-$RANDOM_SUFFIX" --create-namespace --timeout 20m \
    --set restore=true,velero.namespace="restore-agent-$RANDOM_SUFFIX" \
    --set s3Config.accessKey="${S3_AK}" --set s3Config.secretKey="${S3_SK}" \
    --set s3Config.bucket="${S3_BUCKET}" --set s3Config.s3Url="${S3_URL}" --set s3Config.region="${S3_REGION}" \
    --set tags.clusterpedia=false --set tags.mysql=false
set +x

#echo "Restore completed, removing temp resources"
set -x
kubectl -n "restore-$RANDOM_SUFFIX" delete migclusters.migration.yinhestor.com host-cluster --ignore-not-found=true
kubectl -n "restore-$RANDOM_SUFFIX" delete migstorages.migration.yinhestor.com default --ignore-not-found=true
helm delete "restore-$RANDOM_SUFFIX" --namespace "restore-$RANDOM_SUFFIX"
kubectl delete ns "restore-$RANDOM_SUFFIX" "restore-agent-$RANDOM_SUFFIX"
set +x

echo "Done"
