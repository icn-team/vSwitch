FROM ubuntu:18.04 as intermediate

WORKDIR /hicn-build

# Use bash shell
SHELL ["/bin/bash", "-c"]

RUN apt-get update
RUN apt-get install -y git ssh curl wget

# External the repos
RUN curl -s https://packagecloud.io/install/repositories/fdio/hicn/script.deb.sh | bash
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash

RUN apt-get install -y cmake libconfig-dev build-essential libasio-dev --no-install-recommends
RUN apt-get update && apt-get install -y supervisor hicn-plugin libhicn \
            vpp-plugin-core  vpp libvppinfra libmemif \
            libssh-4 openssl libpcre3 

# Libraries to build 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  git \
  cmake \
  build-essential \
  libasio-dev \
  vpp-dev \
  libhicn-dev \
  hicn-plugin-dev \
  libmemif-dev \
  libssh-dev \
  libssl-dev \
  libpcre3-dev \
  python3-ply \
  --no-install-recommends

# Fetch code to build
RUN git clone --depth 1 https://github.com/FDio/hicn.git
RUN git clone --depth 1 --branch v1.0.184 https://github.com/CESNET/libyang.git
RUN git clone --depth 1 --branch v1.4.70 https://github.com/sysrepo/sysrepo.git
RUN git clone --depth 1 --branch v1.1.26 https://github.com/CESNET/libnetconf2.git 
RUN git clone --depth 1 --branch v1.1.39 https://github.com/CESNET/netopeer2.git

# Build hicn-sysrepo-plugin libnetconf2 netopeer2
RUN mkdir buildroot-hicn
RUN mkdir buildroot-libyang
RUN mkdir buildroot-sysrepo
RUN mkdir buildroot-libnetconf2
RUN mkdir buildroot-netopeer2

WORKDIR /hicn-build/buildroot-libyang
RUN cmake -DCMAKE_INSTALL_PREFIX=/hicn-root ../libyang
RUN make -j 4 install 

WORKDIR /hicn-build/buildroot-sysrepo
RUN cmake -DCMAKE_INSTALL_PREFIX=/hicn-root ../sysrepo
RUN make VERBOSE=1 -j 4 install

#WORKDIR /hicn-build/buildroot-hicn
#RUN cmake -DCMAKE_INSTALL_PREFIX=/hicn-root \
#          -DSRPD_PLUGINS_PATH=/usr/lib/x86_64-linux-gnu/ \
#          ../hicn/ctrl/sysrepo-plugins
#RUN make VERBOSE=1 -j 4 install 

WORKDIR /hicn-build/buildroot-libnetconf2
RUN cmake -DCMAKE_INSTALL_PREFIX=/hicn-root ../libnetconf2
RUN make -j 4 install 

WORKDIR /hicn-build/buildroot-netopeer2
RUN cmake -DCMAKE_INSTALL_PREFIX=/hicn-root ../netopeer2 
RUN make -j 4 install

# Final container

FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y git ssh curl wget

# External the repos
RUN curl -s https://packagecloud.io/install/repositories/fdio/hicn/script.deb.sh | bash
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash

RUN apt-get install -y cmake libconfig-dev build-essential libasio-dev --no-install-recommends
RUN apt-get update && apt-get install -y supervisor hicn-plugin libhicn \
            vpp-plugin-core  vpp libvppinfra libmemif \
            libssh-4 openssl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

COPY --from=intermediate /hicn-root /

WORKDIR /
COPY scripts/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

COPY scripts/init.sh /tmp/init.sh
COPY scripts/startup_template.conf /tmp/startup_template.conf
#ENTRYPOINT ["/bin/bash", "/tmp/init.sh"]
