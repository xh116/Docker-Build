FROM alpine:edge AS builder

LABEL maintainer="cx@tinyserve.com" 

# install deps 
RUN  apk --update --no-cache add \
     ca-certificates \
     wget \
     git \
     curl \
     python3 \
     autoconf \
     bison \
     flex \
     gcc \
     g++ \
     linux-headers \
     m4 \
     make \
     ncurses-dev \
     readline-dev \
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
   #curl -sSLo /tmp/Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb && \
    curl -sSLo /tmp/Country.mmdb https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb && \
    git clone -b gh-pages  https://github.com/haishanh/yacd.git /tmp/yacd 
    
# build bird from https://gitlab.labs.nic.cz
RUN  cd /tmp && \
     git clone --shallow-submodules --recurse-submodules https://gitlab.labs.nic.cz/labs/bird/ /tmp/bird && cd /tmp/bird && \
     git checkout "$(git describe --tags `git rev-list --tags --max-count=1`)" && \
     autoreconf && \
     ./configure \
     --prefix=/usr \
     --localstatedir=/var \
     --sysconfdir=/etc/bird \
     --runstatedir=/run/bird && \
     make 
     
# gen nchnroutes from https://github.com/dndx/nchnroutes
RUN  cd /tmp && \
     git clone https://github.com/dndx/nchnroutes.git /tmp/nchnroutes && \
     cd /tmp/nchnroutes && \
     curl -sSLo delegated-apnic-latest https://ftp.apnic.net/stats/apnic/delegated-apnic-latest && \
     #curl -sSLo china_ip_list.txt https://raw.githubusercontent.com/hezhijie0327/CNIPDb/main/cnipdb_ipv4.txt
     curl -sSLo china_ip_list.txt https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt 
     
RUN  cd /tmp && \
     s6_version=$(curl -sL https://api.github.com/repos/just-containers/s6-overlay/releases/latest | jq -r ".tag_name") && \
     ARCH=$(apk info --print-arch) && \
     case "$ARCH" in \
      x86_64) s6_arch=x86_64 ;; \
      aarch64) s6_arch=aarch64 ;; \
      armv7) s6_arch=arm ;; \
      *) s6_arch="$ARCH" ;; \
      esac && \
     curl -sSLo /tmp/s6-overlay.tar.xz https://github.com/just-containers/s6-overlay/releases/download/$s6_version/s6-overlay-$s6_arch.tar.xz && mkdir /tmp/s6 && \
     tar -C /tmp/s6 -Jxpf /tmp/s6-overlay.tar.xz && \
     curl -sSLo /tmp/s6-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/$s6_version/s6-overlay-noarch.tar.xz && \
     tar -C /tmp/s6 -Jxpf /tmp/s6-noarch.tar.xz 
     
FROM  alpine:edge

COPY --from=builder /tmp/clash/clash /usr/local/bin
COPY --from=builder /tmp/Country.mmdb /etc/clash/
COPY --from=builder /tmp/yacd /etc/clash/ui
COPY --from=builder /tmp/bird/bird /tmp/bird/birdc /tmp/bird/birdcl /usr/local/sbin/
COPY --from=builder /tmp/nchnroutes /nchnroutes
COPY --from=builder /tmp/s6 /
COPY Blash/gfwgen-regex /usr/local/bin
COPY Blash/overlay/ / 
 
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf   

RUN  chmod +x /usr/local/bin/clash && \
     chmod +x /usr/local/bin/gfwgen-regex && \
     chmod +x /etc/cont-init.d/run.sh && \
     mkdir /etc/bird /run/bird && \
     apk --update --no-cache add \
     ca-certificates \
     iproute2 \
     curl \
     python3 \
     tzdata && \
     cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
     apk del tzdata && \
     rm -rf /tmp/* /var/cache/apk/*

ENTRYPOINT ["/init"]
