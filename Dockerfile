FROM ubuntu:18.04

RUN apt-get update && apt-get install -y curl libprotobuf-c1 libev4 libavl1 libssh-4

RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update && apt-get install -y supervisor hicn-plugin vpp-plugin-dpdk

RUN echo "deb [trusted=yes] https://dl.bintray.com/icn-team/apt-hicn-extras bionic main" | tee -a /etc/apt/sources.list
RUN apt-get update && apt-get install libyang -y sysrepo libnetconf2 netopeer2

WORKDIR /
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"