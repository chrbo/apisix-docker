```shell
docker buildx build --platform linux/amd64,linux/arm64 . -t registry.cloud.vitaservices-dev.de/healthmatch/container-images/apisix:3.7.0-1.25.3.2-5-alpine --push
```