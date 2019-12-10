#FROM ubuntu:18.04
FROM arm64v8/ubuntu:18.04

# Build sysrepo suite

WORKDIR /hicn-build
SHELL ["/bin/bash", "-c"]

# Install vpp
RUN apt-get update && apt-get install -y curl
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update && apt-get install -y hicn-plugin hicn-plugin-dev vpp libvppinfra \
    vpp-plugin-core vpp-dev libparc libparc-dev python3-ply python python-ply

# Install main packages
RUN apt-get install -y git cmake build-essential libpcre3-dev swig \
  libprotobuf-c-dev libev-dev libavl-dev protobuf-c-compiler libssl-dev \
  libssh-dev libcurl4-openssl-dev libasio-dev libconfig-dev --no-install-recommends openssh-server