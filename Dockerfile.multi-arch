FROM --platform=${TARGETPLATFORM} registry.cn-shanghai.aliyuncs.com/jibudata/ubi8-minimal:8.5

# tzdata must be installed for timezone support
# tar must be installed for file download from user cluster through kubectl cp
RUN rpm --erase --quiet --nodeps tzdata && microdnf install tzdata tar

WORKDIR /ys1000

COPY docs docs
COPY offline offline

ENTRYPOINT ["tail", "-f", "/dev/null"]

