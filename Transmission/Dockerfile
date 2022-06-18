FROM alpine:edge AS builder
 
# Install deps
RUN set -x \
    # Install build dependencies
 && apk update && apk add --no-cache -t .build-deps  \
      transmission-daemon \
      autoconf \
      automake \
      build-base \
      linux-headers \
      bsd-compat-headers \
      dbus-glib-dev \
      gcc \
      g++ \
      gettext \
      musl-dev \
      gettext \
      intltool \
      libtool \
      libevent-dev \
      libnotify-dev \
      openssl-dev \
      miniupnpc-dev \
      musl-dev \
      m4 \
      curl-dev \
      curl \
      cmake \
      make \
      git  \
      jq

# Build TRM
RUN set -x && \
    cd /tmp && \
    git clone --shallow-submodules --recurse-submodules https://github.com/transmission/transmission  /tmp/Transmission && cd /tmp/Transmission && \
    git checkout "$(git describe --tags `git rev-list --tags --max-count=1`)"  && \
    mkdir build && cd build && \
    cmake  -D CMAKE_INSTALL_PREFIX="/usr/local" \
           -D CMAKE_BUILD_TYPE=RelWithDebInfo .. && \
    make && \
    make install
    
# Download Webui
RUN set -x && \
    cd /tmp/  &&  \
    git clone --shallow-submodules --recurse-submodules https://github.com/ronggang/transmission-web-control.git /tmp/transmission-web-control &&  cd /tmp/transmission-web-control &&  \
    git checkout "$(git describe --tags `git rev-list --tags --max-count=1`)"  && \
    mv src  transmission-web-control     
  #  export version=$(curl -s "https://api.github.com/repos/ronggang/transmission-web-control/releases/latest" | jq -r .tag_name) &&  \
  #  curl -sSLo /tmp/transmission-web-control.tar.gz https://github.com/ronggang/transmission-web-control/archive/${version}.tar.gz && \
  #  tar -zxvf /tmp/transmission-web-control.tar.gz  -C . && rm transmission-web-control.tar.gz  && \
  #  cd transmission-* && mv src  transmission-web-control 
  # Clean-up
   # apk del --purge .build-deps && \
   # rm -rf /var/cache/apk/*

FROM alpine:edge

RUN apk update && apk add --no-cache \
    ca-certificates \
    libcurl \
    libintl \
    libevent \
    libstdc++ \
    libgcc \
    miniupnpc \
    openssl \
    su-exec \
    dumb-init \
    tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk del tzdata && \
    rm -rf /tmp/* /var/cache/apk/*
 
COPY --from=builder /usr/share/transmission/  /usr/share/transmission/
COPY --from=builder /tmp/transmission-web-control/transmission-web-control /transmission-web-control 
COPY --from=builder /usr/local/bin/transmission-* /usr/local/bin/ 
COPY Transmission/entrypoint.sh /entrypoint.sh

ENV TRANSMISSION_HOME="/var/lib/transmission" \
  TRANSMISSION_WEB_HOME="/transmission-web-control" \
  USERNAME="admin" \
  PASSWORD="password" \
  RPC_PORT="9091" \
  PEER_PORT="51413" \
  PUID="1024" \
  PGID="1024"

RUN chmod a+x /entrypoint.sh  && \
    mkdir -p /var/lib/transmission  && \
    mkdir -p /downloads/incomplete  && \
    addgroup -g ${PGID} transmission && \
    adduser -D -h ${TRANSMISSION_HOME} -u ${PUID} -G transmission -s /bin/sh transmission && \
    ln -s /usr/share/transmission/web/style /transmission-web-control && \
    ln -s /usr/share/transmission/web/images /transmission-web-control && \
    ln -s /usr/share/transmission/web/javascript /transmission-web-control && \
    ln -s /usr/share/transmission/web/index.html /transmission-web-control/index.original.html
  
VOLUME ["/config","/downloads","/watch"]

EXPOSE 9091 51413/tcp 51413/udp
 
ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD transmission-daemon -g /config -w /downloads -c /watch  -f 
