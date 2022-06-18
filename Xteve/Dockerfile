FROM golang:alpine AS builder

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOPATH=/go
ENV GOBIN=/go/bin


RUN apk add --no-cache git \
    && git clone https://github.com/xteve-project/xTeVe.git /xteve-src     
WORKDIR /xteve-src 

RUN go get github.com/koron/go-ssdp \
    && go get github.com/gorilla/websocket \
    && go get github.com/kardianos/osext \
    && go build -o /xteve xteve.go 
 
FROM alpine:latest

LABEL maintainer="cx@tinyserve.com"

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    ffmpeg \
    vlc &&\
    sed -i 's/geteuid/getppid/' /usr/bin/vlc &&\
    rm -rf /var/cache/apk/*  

WORKDIR /xteve
COPY --from=builder /xteve xteve

ENTRYPOINT ["/xteve/xteve"]

CMD ["-port=34400" , "-config=/xteve/config"]
