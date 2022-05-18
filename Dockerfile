FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=

RUN apt-get update
RUN apt-get install -y git ssh curl wget iproute2

# External the repos
RUN curl -s https://packagecloud.io/install/repositories/fdio/2202/script.deb.sh | bash
RUN curl -s https://packagecloud.io/install/repositories/fdio/hicn/script.deb.sh | bash

RUN apt-get update && apt-get install -y \
            hicn-plugin \
            vpp-plugin-core \
            vpp \
            libvppinfra \
            libssh-4 \
            openssl \
            libpcre3 \
            iproute2 \
            iptables \
            frr \
            net-tools\
            iputils-ping \
            tini \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

#ENTRYPOINT ["/bin/bash", "/tmp/init.sh"]
