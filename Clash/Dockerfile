FROM alpine:edge AS builder

LABEL maintainer="cx@tinyserve.com" 

# install deps 
RUN  apk --update --no-cache add \
     ca-certificates \
     wget \
     git \
     curl \
     unzip  \
     gzip \
     jq \
     xz \
     zlib-dev     

# download clash premium 
RUN cd /tmp && \
    VERSION=$(curl -s https://api.github.com/repos/Dreamacro/clash/releases | jq -r .[]."name" | grep -m1 -E "Premium ([0-9]{1,2}\.?){3,4}$" | sed "s/Premium //") && \
    ARCH=$(apk info --print-arch) && \
    echo ARCH=$ARCH && \
    case "$ARCH" in \
     x86_64) arch=amd64 ;; \
     aarch64) arch=armv8 ;; \
     armv7) arch=armv7 ;; \
      *) arch="$ARCH" ;; \
    esac && \
    wget -P /tmp/clash https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-$arch-$VERSION.gz && \
    gunzip /tmp/clash/clash-linux-$arch-$VERSION.gz && \
    mv /tmp/clash/clash-linux-$arch-$VERSION /tmp/clash/clash

# get clash requirements 
RUN cd /tmp && \
    curl -sSLo /tmp/Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb && \
    git clone -b gh-pages  https://github.com/haishanh/yacd.git /tmp/yacd 
    
      
FROM  alpine:edge

COPY --from=builder /tmp/clash/clash /usr/local/bin
COPY --from=builder /tmp/Country.mmdb /etc/clash/
COPY --from=builder /tmp/yacd /etc/clash/ui 
COPY Clash/config.yaml  /etc/clash/

RUN  chmod +x /usr/local/bin/clash && \
     apk --update --no-cache add \
     ca-certificates \
     tzdata && \
     cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
     apk del tzdata && \
     rm -rf /tmp/* /var/cache/apk/*

CMD ["/usr/local/bin/clash", "-d", "/etc/clash"]
