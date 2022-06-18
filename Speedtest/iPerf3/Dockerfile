FROM alpine:latest

LABEL maintainer="cx@tinyserve.com"

RUN apk add --no-cache iperf3 &&\
    rm -rf /var/cache/apk/* &&\    
    iperf3 --version
 
EXPOSE 5201/tcp 5201/udp
ENTRYPOINT ["iperf3"]
CMD ["-s"]
