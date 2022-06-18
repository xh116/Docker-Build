FROM alpine:latest

ARG VERSION=1.1.1
ENV SPEEDTEST_VERSION=${VERSION}

LABEL maintainer="cx@tinyserve.com"


# ADD https://install.speedtest.net/app/cli/ookla-speedtest-${VERSION}-linux-${_arch}.tgz \
#   /tmp/ookla-speedtest.tgz

RUN apk add --no-cache --virtual deps tar curl && \
    ARCH=$(apk info --print-arch) && \
    echo ARCH=$ARCH && \
    case "$ARCH" in \
    # x86) _arch=i386 ;; \
     x86_64) _arch=x86_64 ;; \
    # aarch64) _arch=aarch64 ;; \
    # armv7) _arch=armhf ;; \
      *) _arch="$ARCH" ;; \
    esac && \
    echo https://install.speedtest.net/app/cli/ookla-speedtest-${VERSION}-linux-${_arch}.tgz && \
    curl -fsSL -o /tmp/ookla-speedtest.tgz \
      https://install.speedtest.net/app/cli/ookla-speedtest-${VERSION}-linux-${_arch}.tgz && \
    tar xvfz /tmp/ookla-speedtest.tgz -C /usr/local/bin speedtest && \
    rm -rf /tmp/ookla-speedtest.tgz && \
    adduser -D speedtest && \
    su speedtest -c "speedtest --accept-license --accept-gdpr" && \
    apk del deps 

USER speedtest

ENTRYPOINT ["/usr/local/bin/speedtest"]
