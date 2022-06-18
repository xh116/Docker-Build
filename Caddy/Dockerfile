FROM golang:alpine AS builder

RUN set -e && \
    apk --update --no-cache add jq curl git && \
   # export version=$(curl -sL https://api.github.com/repos/caddyserver/caddy/releases/latest | jq -r ".tag_name")  && \
    export version=$(curl -fsSL https://api.github.com/repos/caddyserver/caddy/releases | \
      grep '"tag_name":' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')  && \
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    xcaddy build ${version} --output /caddy \
       --with github.com/caddyserver/forwardproxy@caddy2=github.com/sagernet/forwardproxy@latest \
       --with github.com/caddy-dns/cloudflare \
       --with github.com/xh116/caddy-trojan \
       --with github.com/mholt/caddy-webdav
         
FROM alpine:latest 

LABEL maintainer="cx@tinyserve.com"
 
# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

ENV TZ Asia/Shanghai

COPY --from=builder /caddy /usr/bin/caddy
ADD https://raw.githubusercontent.com/caddyserver/dist/master/config/Caddyfile /etc/caddy/Caddyfile
ADD https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html /usr/share/caddy/index.html
 
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf
 
RUN set -e &&\
    apk --update --no-cache add  \
    ca-certificates \
    tzdata \
    mailcap && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime  && \
    echo ${TZ} > /etc/timezone && \
    rm -rf /var/cache/apk/*

VOLUME /config
VOLUME /data

EXPOSE 80
EXPOSE 443
# EXPOSE 2019

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
