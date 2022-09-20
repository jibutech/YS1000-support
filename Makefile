
TAG ?= $(shell git rev-parse --abbrev-ref HEAD).$(shell git rev-parse --short HEAD)

# Image URL to use all building/pushing image targets
IMG ?= registry.cn-shanghai.aliyuncs.com/jibudata/ys1000-offline-installer:$(TAG)


build:
	docker build -f ./Dockerfile -t ${IMG} .

push:
	docker push ${IMG}
