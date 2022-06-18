FROM golang:alpine AS builder

RUN set -e \
    && apk upgrade \
    && apk add --no-cache musl-dev git gcc \
    && git clone https://github.com/ginuerzh/gost.git \
    && cd gost/cmd/gost && go env && go build -v 

FROM alpine:latest

LABEL maintainer="cx@tinyserve.com"

ENV TZ Asia/Shanghai

RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

RUN set -e \
    && apk upgrade \
    && apk add bash tzdata mailcap \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /var/cache/apk/* 
    
WORKDIR /bin/ 

COPY --from=builder  /go/gost/cmd/gost/gost .

ENTRYPOINT ["/bin/gost"]
CMD ["-C", "gost.json"]
