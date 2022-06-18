FROM alpine

RUN apk add --no-cache openssh nano curl 

RUN set -eux; \
    ssh-keygen -A; \
    sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' -i /etc/ssh/sshd_config; \
    (echo 'password'; echo 'password') | passwd root

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
