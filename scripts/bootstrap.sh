#!/usr/bin/env bash
apt-get update && apt-get install -y curl
curl -s https://packagecloud.io/install/repositories/fdio/2202/script.deb.sh | bash
curl -s https://packagecloud.io/install/repositories/fdio/hicn/script.deb.sh | bash
apt-get update && apt-get install -y \
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
