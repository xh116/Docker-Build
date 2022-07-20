FROM alpine:edge AS builder
LABEL maintainer="cx@tinyserve.com" 


# Compiling qBitTorrent following instructions on
# https://github.com/qbittorrent/qBittorrent/wiki/Compilation%3A-Alpine-Linux
RUN set -x &&\
    # Install build dependencies
    # echo https://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community  >> /etc/apk/repositories && \
    apk update && apk add --no-cache -t .build-deps \
    autoconf \
    automake \
    build-base \
    cmake \
    curl \
    git \
    libtool \
    linux-headers \
    perl \
    pkgconf \
    python3 \
    python3-dev \
    re2c \
    tar  \
    unzip \
    icu-dev \
    libexecinfo-dev \
    openssl-dev \
    qt6-qtbase-dev \
    qt6-qttools-dev \
    zlib-dev \
    qt6-qtsvg-dev

# Build Ninja from source
RUN cd /tmp \
&& git clone --shallow-submodules --recurse-submodules https://github.com/ninja-build/ninja.git  /tmp/ninja && cd /tmp/ninja \
&& git checkout "$(git tag -l --sort=-v:refname "v*" | head -n 1)" \
&& cmake -Wno-dev -B build  \
    -D CMAKE_CXX_STANDARD=17 \
    -D CMAKE_INSTALL_PREFIX="/usr/local" \
&& cmake --build build \
&& cmake --install build

  #Download boost http://www.boost.org/
RUN cd /tmp \
&& curl -fsSL https://boostorg.jfrog.io/artifactory/main/beta/1.80.0.beta1/source/boost_1_80_0_b1.tar.gz -o "/tmp/boost.tar.gz" \
&& tar xf "/tmp/boost.tar.gz" -C "/tmp" && mv /tmp/boost_* /tmp/boost

    # Build lib rasterbar from source code (required by qBittorrent)
 RUN cd /tmp \
 && git clone --recurse-submodules https://github.com/arvidn/libtorrent.git /tmp/libtorrent-rasterbar  && cd /tmp/libtorrent-rasterbar \
 #&& git checkout "$(git tag -l --sort=-v:refname "v2*" | head -n 1)" \
 && cmake -Wno-dev -G Ninja -B build \
    -D CMAKE_BUILD_TYPE="Release" \
    -D CMAKE_CXX_STANDARD=17 \
    -D BOOST_INCLUDEDIR="/tmp/boost" \
    -D CMAKE_INSTALL_LIBDIR="lib" \
    -D CMAKE_INSTALL_PREFIX="/usr/local" \
 && cmake --build build \
 && cmake --install build \
 && mkdir -p /lib64 \
 && cp -P /usr/local/lib/libtorrent-rasterbar.so* /lib64
 
    # Build qBittorrent from source code
 RUN cd /tmp \
 && git clone --shallow-submodules --recurse-submodules https://github.com/qbittorrent/qBittorrent.git /tmp/qbittorrent  && cd /tmp/qbittorrent \
 && git checkout "$(git describe --tags `git rev-list --tags --max-count=1`)" \
 && curl -sSLo /tmp/www.zip https://github.com/crash0verride11/DarkLight-qBittorent-WebUI/releases/download/release/www.zip  \
 && unzip /tmp/www.zip -d /www \
 && cmake -Wno-dev -G Ninja -B build \
    -D QT6=ON \
    -D STACKTRACE=OFF \
    -D GUI=OFF \
    -D CMAKE_BUILD_TYPE="release" \
    -D CMAKE_CXX_STANDARD=17 \
    -D BOOST_INCLUDEDIR="/tmp/boost" \
    -D CMAKE_CXX_STANDARD_LIBRARIES="/usr/lib/libexecinfo.so" \
    -D CMAKE_INSTALL_PREFIX="/usr/local" \
&& cmake --build build \
&& cmake --install build \  
# Clean-up
&& apk del --purge .build-deps \
&& rm -rf /tmp/* /var/cache/apk/*


FROM alpine:edge

LABEL maintainer="cx@tinyserve.com" 

COPY --from=builder  /lib64 /usr/lib/
COPY --from=builder /www/www/public  /opt/dark_light/public
COPY --from=builder /www/www/private /opt/dark_light/private
COPY --from=builder /usr/local/bin/qbittorrent-nox /usr/bin/qbittorrent-nox
COPY qBittorrent/entrypoint.sh /entrypoint.sh

# Install required packages
RUN apk --update --no-cache add \
        ca-certificates \
        qt6-qtbase \
        dumb-init \
        su-exec \
        mktorrent \
        tzdata && \
        cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
        apk del tzdata && \
        rm -rf /tmp/* /var/cache/apk/*

ENV QBITTORRENT_HOME="/home/qbittorrent" \
  WEBUI_PORT="8081" \
  SESSION_PORT="56881" \
  PUID="1024" \
  PGID="1024"
 
RUN chmod a+x /entrypoint.sh && \
   addgroup -g ${PGID} qbittorrent && \
   adduser -D -h ${QBITTORRENT_HOME} -u ${PUID} -G qbittorrent -s /bin/sh qbittorrent && \
   mkdir -p ${QBITTORRENT_HOME}/.config/qBittorrent && \
   mkdir -p ${QBITTORRENT_HOME}/.local/share/qBittorrent && \
   mkdir -p /downloads/incomplete/torrents && mkdir -p /downloads/torrents && \
   ln -s ${QBITTORRENT_HOME}/.config/qBittorrent /config && \
   ln -s ${QBITTORRENT_HOME}/.local/share/qBittorrent /data
   
VOLUME ["/config", "/data", "/downloads" ]

EXPOSE ${WEBUI_PORT} ${SESSION_PORT} ${SESSION_PORT}/udp

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD [ "/usr/bin/qbittorrent-nox" ]
