FROM golang:alpine AS builder

LABEL maintainer="cx@tinyserve.com" 

RUN  echo https://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community  >> /etc/apk/repositories && \
     apk --update --no-cache add \
     git \
     build-base 
     
RUN cd /tmp  &&\
    git clone --shallow-submodules --recurse-submodules https://github.com/HyNetwork/hysteria.git  /tmp/hysteria && cd /tmp/hysteria/cmd && \
    go build -trimpath -ldflags="-s -w -X 'main.appVersion=$(git describe --tags `git rev-list --tags --max-count=1`)'\
    -X 'main.appDate=`date +'%Y-%m-%d %H:%M:%S'`' \
    -X 'main.appCommit=$(git rev-list HEAD --max-count=1)' " \
    -o hysteria . 
    
    
FROM alpine:latest 
LABEL maintainer="cx@tinyserve.com" 

COPY --from=builder /tmp/hysteria/cmd/hysteria /usr/local/bin/hysteria
COPY Hysteria/entrypoint.sh /entrypoint.sh

RUN  apk --update --no-cache add \
     ca-certificates \
     dumb-init \
     tzdata && \
     chmod +x /entrypoint.sh && \
     cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
     apk del tzdata && \
     rm -rf /tmp/* /var/cache/apk/*
     
     
ENTRYPOINT ["dumb-init","/entrypoint.sh"]

