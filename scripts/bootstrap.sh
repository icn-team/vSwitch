#!/usr/bin/env bash
apt-get update && apt-get install -y curl
curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | sudo bash
apt-get update && apt-get install -y hicn-plugin hicn-plugin-dev vpp libvppinfra libhicn-dev\
        vpp-plugin-core vpp-dev libparc libparc-dev python3-ply python python-ply vpp-plugin-dpdk\
        hicn-utils-memif hicn-collectd-plugins
echo "deb [trusted=yes] https://dl.bintray.com/icn-team/apt-hicn-extras bionic main" | tee -a /etc/apt/sources.list
apt-get update && apt-get install -y libyang sysrepo libnetconf2 netopeer2-server
