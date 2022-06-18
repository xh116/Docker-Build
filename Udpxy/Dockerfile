
FROM alpine:latest AS builder
 

LABEL maintainer="cx@tinyserve.com"

 
WORKDIR /tmp

RUN apk --no-cache update && apk add make git gcc libc-dev 
 
RUN  cd /tmp \
 && git clone --shallow-submodules --recurse-submodules https://github.com/pcherenkov/udpxy.git /tmp/udpxy  && cd /tmp/udpxy \
 && git checkout "$(git describe --tags `git rev-list --tags --max-count=1`)" \
 && cd chipmunk && make && make install
    
FROM alpine:latest
    
COPY --from=builder /usr/local/bin/udpxy /usr/local/bin/udpxy
COPY --from=builder /usr/local/bin/udpxrec /usr/local/bin/udpxrec

ENTRYPOINT ["/usr/local/bin/udpxy"]
CMD ["-vTS", "-p", "4022"]
