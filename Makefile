
TAG ?= $(shell git rev-parse --abbrev-ref HEAD).$(shell git rev-parse --short HEAD)

# Image URL to use all building/pushing image targets
IMG ?= registry.cn-shanghai.aliyuncs.com/jibutech/ys1000-offline-installer


build:
	docker buildx build --platform linux/amd64,linux/arm64 -f ./Dockerfile -t ${IMG}:${TAG} .
	#docker build -f ./Dockerfile -t ${IMG}:${TAG} .

push:
	docker buildx build --platform linux/amd64,linux/arm64 -f ./Dockerfile -t ${IMG}:${TAG} . --push
