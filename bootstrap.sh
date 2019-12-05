#!/usr/bin/env bash
apt-get update && apt-get install -y curl
curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
apt-get update && apt-get install -y hicn-plugin hicn-plugin-dev vpp libvppinfra libhicn-dev\
        vpp-plugin-core vpp-dev libparc libparc-dev python3-ply python python-ply

# Install main packages
apt-get install -y git cmake build-essential libpcre3-dev swig \
  libprotobuf-c-dev libev-dev libavl-dev protobuf-c-compiler libssl-dev \
  libssh-dev libcurl4-openssl-dev libasio-dev libconfig-dev --no-install-recommends openssh-server \
  ###############################################
  # Build libyang
  ################################################
  git clone https://github.com/CESNET/libyang --branch devel --depth 1
  mkdir -p libyang/build
  cd libyang/build && cmake -DCMAKE_BUILD_TYPE=Release ..
  make -j 4 install && cd /home/vagrant 
  ########################################################################################
  # Build sysrepo
  ########################################################################################
  git clone https://github.com/sysrepo/sysrepo.git --branch devel --depth 1
  mkdir -p sysrepo/build
  cd sysrepo/build && cmake -DCMAKE_BUILD_TYPE:String="Release" ..
  make -j 4 install && ldconfig && cd /home/vagrant
 ############################################################
  # Build libnetconf2
  ############################################################
  git clone https://github.com/CESNET/libnetconf2 --branch devel --depth 1
  mkdir -p libnetconf2/build
  cd libnetconf2/build && cmake -DCMAKE_BUILD_TYPE=Release ..
  make -j4 install && cd /home/vagrant
  ############################################################
  # Build Netopeer
  ############################################################
  git clone https://github.com/CESNET/Netopeer2 --branch devel-server --depth 1
  mkdir -p Netopeer2/server/build
  cd Netopeer2/server/build && cmake -DCMAKE_BUILD_TYPE=Release ..
  make -j 4 install && cd /home/vagrant
