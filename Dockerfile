FROM ubuntu:18.04

RUN apt-get update && apt-get install -y curl

RUN echo "deb [trusted=yes] https://dl.bintray.com/icn-team/apt-hicn-extras bionic main" | tee -a /etc/apt/sources.list
RUN apt-get update && apt-get install -y libyang sysrepo libnetconf2 netopeer2-server

RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update && apt-get install -y supervisor hicn-plugin vpp-plugin-dpdk hicn-sysrepo-plugin

RUN bash /usr/bin/setup.sh sysrepoctl /usr/lib/x86_64-linux-gnu/modules_yang/ root
RUN bash /usr/bin/merge_hostkey.sh sysrepocfg openssl
RUN bash /usr/bin/merge_config.sh sysrepocfg genkey

WORKDIR /
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
