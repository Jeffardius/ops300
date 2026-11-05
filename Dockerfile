FROM docker.io/library/ubuntu:26.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends bind9 bind9-utils && \
    rm -rf /var/lib/apt/lists/*

COPY named.conf /etc/bind/named.conf
COPY named.conf.options /etc/bind/named.conf.options
COPY named.conf.local /etc/bind/named.conf.local

EXPOSE 53/tcp 53/udp

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf"]
