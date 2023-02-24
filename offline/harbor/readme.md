helm upgrade --install -n harbor --create-namespace harbor harbor-16.3.1.tgz --set externalURL=<集群外访问的URL> --set persistence.imageChartStorage.type=s3 --set persistence.imageChartStorage.s3.region=<region> --set persistence.imageChartStorage.s3.bucket=<bucket> --set persistence.imageChartStorage.s3.accesskey=<ak> --set persistence.imageChartStorage.s3.secretkey=<sk> --set persistence.imageChartStorage.s3.regionendpoint=<s3 endpoint> --set global.storageClass=<storage class>

k -n harbor get secrets harbor-core-envvars -o yaml | yq '.data.HARBOR_ADMIN_PASSWORD' | base64 -d

