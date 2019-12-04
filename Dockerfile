
FROM ubuntu:18.04 as intermediate

# Build sysrepo suite

WORKDIR /hicn-build

SHELL ["/bin/bash", "-c"]

# Install vpp
RUN apt-get update && apt-get install -y curl
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update && apt-get install -y hicn-plugin hicn-plugin-dev vpp libvppinfra libhicn-dev\
    vpp-plugin-core vpp-dev libparc libparc-dev python3-ply python python-ply python3-dev

# Install main packages
RUN apt-get install -y git cmake build-essential libpcre3-dev swig                              \
  libprotobuf-c-dev libev-dev libavl-dev protobuf-c-compiler libssl-dev                         \
  libssh-dev libcurl4-openssl-dev libasio-dev libconfig-dev                                     \
  --no-install-recommends openssh-server                                                        \
  ##############################################                                                \
  # Build libyang                                                                               \
  ##############################################                                                \
  && git clone https://github.com/CESNET/libyang --branch devel --depth 1                       \
  && mkdir -p libyang/build                                                                     \
  && pushd libyang/build && cmake -DCMAKE_BUILD_TYPE=Release  -DGEN_LANGUAGE_BINDINGS=ON ..     \
  && make -j 4 install && popd                                                                  \
  ##############################################                                                \
  # Build sysrepo                                                                               \
  ##############################################                                                \
  && git clone https://github.com/sysrepo/sysrepo.git --branch devel --depth 1                  \
  && mkdir -p sysrepo/build                                                                     \
  && pushd sysrepo/build && cmake -DCMAKE_BUILD_TYPE=Release  ..                                \
  && make -j 4 install && ldconfig && popd                                                      \
 ###############################################                                                \
  # Build libnetconf2                                                                           \
  ##############################################                                                \
  && git clone https://github.com/CESNET/libnetconf2 --branch devel --depth 1                   \
  && mkdir -p libnetconf2/build                                                                 \
  && pushd libnetconf2/build && cmake -DCMAKE_BUILD_TYPE=Release ..                             \ 
  && make -j4 install && popd                                                                   \
  ##############################################                                                \
  # Build Netopeer                                                                              \
  ##############################################                                                \
  && git clone https://github.com/CESNET/Netopeer2 --branch devel-server --depth 1              \
  && mkdir -p Netopeer2/server/build                                                            \
  && pushd Netopeer2/server/build && cmake -DCMAKE_BUILD_TYPE=Release ..                        \
  && make -j 4 install && popd                                                                   
 
  RUN git clone https://git.fd.io/hicn                                                          \
  && mkdir -p hicn/ctrl/sysrepo-plugins/build && pushd hicn/ctrl/sysrepo-plugins/build          \
  && cmake .. && make -j4 && make install && popd

# Install hicn module in sysrepo
ENV YANG_MODEL_INSTALL_SCRIPT=https://raw.githubusercontent.com/icn-team/vSwitch/master/yang_fetch.sh
ENV YANG_MODEL_LIST=https://raw.githubusercontent.com/icn-team/vSwitch/master/yang_list.txt
RUN curl -OL ${YANG_MODEL_LIST} && curl -s ${YANG_MODEL_INSTALL_SCRIPT} | TERM="xterm" bash -x  

FROM ubuntu:18.04

COPY --from=intermediate /usr/local /usr/local
COPY --from=intermediate /etc/sysrepo /etc/sysrepo
RUN apt-get update && apt-get install -y curl libprotobuf-c1 libev4 libavl1 libssh-4
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update && apt-get install -y supervisor hicn-plugin vpp-plugin-dpdk
RUN mkdir -p /usr/local/lib/sysrepo/plugins && ldconfig

WORKDIR /
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
