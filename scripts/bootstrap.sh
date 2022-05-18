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

sudo mkdir -p /var/log/vpp
sudo tee /etc/vpp/startup.conf <<EOF
cpu { main-core 1 }
plugins {
path /usr/lib/x86_64-linux-gnu/vpp_plugins:/usr/lib/vpp_plugins
plugin default { disable }
plugin acl_plugin.so { enable }
plugin nat_plugin.so { enable }
plugin dhcp_plugin.so { enable }
plugin dpdk_plugin.so { enable }
plugin dns_plugin.so { enable }
plugin ping_plugin.so { enable }
plugin memif_plugin.so { enable }
plugin nsim_plugin.so { enable }
plugin hicn_plugin.so { enable }

}

unix {
startup-config /etc/vpp/client-up.txt
cli-listen /run/vpp/cli.sock
log /var/log/vpp/vpp.log
}
EOF