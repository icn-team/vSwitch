FROM ubuntu:18.04 as intermediate

# Build sysrepo suite

WORKDIR /hicn-build


RUN mkdir /hicn-root

# Use bash shell
SHELL ["/bin/bash", "-c"]


# Install vpp
RUN apt-get update && apt-get install -y curl
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update && apt-get install -y hicn-plugin hicn-plugin-dev vpp libvppinfra vpp-plugin-core vpp-dev libparc libparc-dev python3-ply python python-ply libhicn-dev

# Install main packages
RUN apt-get install -y git cmake build-essential libpcre3-dev swig \
  libprotobuf-c-dev libev-dev libavl-dev protobuf-c-compiler libssl-dev \
  libssh-dev libcurl4-openssl-dev libasio-dev libconfig-dev --no-install-recommends openssh-server \
  ###############################################                                               \
  # Build libyang                                                                               \
  ################################################                                              \
  && git clone https://github.com/CESNET/libyang                                                \
  && mkdir -p libyang/build                                                                     \
  && pushd libyang/build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/hicn-root .. && make -j 4 install && popd   \
  ########################################################################################      \
  # Build sysrepo                                                                               \
  ########################################################################################      \
  && git clone https://github.com/sysrepo/sysrepo.git                                           \
  && mkdir -p sysrepo/build                                                                     \
  && sed -i 's/\/etc\/sysrepo/\/hicn-root/' sysrepo/CMakeLists.txt                              \
  && pushd sysrepo/build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/hicn-root -DREPOSITORY_LOC=/hicn-root ..  \
  && make -j 4 install && popd                                                                  \
  ############################################################                                  \
  # Build libnetconf2                                                                           \
  ############################################################                                  \
  && git clone https://github.com/CESNET/libnetconf2                                            \
  && mkdir -p libnetconf2/build                                                                 \
  && pushd libnetconf2/build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/hicn-root .. && make -j4 install && popd\
  ############################################################                                  \
  # Build Netopeer                                                                              \
  ############################################################                                  \
  && git clone https://github.com/CESNET/Netopeer2                                              \
  && mkdir -p Netopeer2/server/build                                                            \
  && pushd Netopeer2/server/build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/hicn-root -DREPOSITORY_LOC=/hicn-root .. \
  && make -j 4 install && popd                                                              
# Hicn sysrepo plugin
RUN git clone https://github.com/FDio/hicn.git                                                 \
  && sed -i 's/#define HICN_PARAM_PIT_ENTRY_PHOPS_MAX 20/#define HICN_PARAM_PIT_ENTRY_PHOPS_MAX 260/g' hicn/hicn-plugin/src/params.h\
  && sed -i 's/${HICNPLUGIN_INCLUDE_DIRS}/${HICNPLUGIN_INCLUDE_DIRS} ${SYSREPO_INCLUDE_DIRS}/' /hicn-build/hicn/ctrl/sysrepo-plugins/hicn-plugin/CMakeLists.txt \
  && mkdir -p hicn/ctrl/sysrepo-plugins/hicn-plugin/build && pushd hicn/ctrl/sysrepo-plugins/hicn-plugin/build  \
  && cmake .. -DSR_PLUGINS_DIR=/hicn-root/lib/sysrepo/plugins/ -DSYSREPO_INCLUDE_MAIN_DIR=/hicn-root/include -DSYSREPO_INCLUDE_DIR=/hicn-root/include -DSYSREPO_LIBRARY=/hicn-root/lib && make -j4 install && popd

# Install hicn module in sysrepo
ENV YANG_MODEL_INSTALL_SCRIPT=https://raw.githubusercontent.com/icn-team/vSwitch/master/yang_fetch.sh
ENV YANG_MODEL_LIST=https://raw.githubusercontent.com/icn-team/vSwitch/master/yang_list.txt
RUN curl -OL ${YANG_MODEL_LIST} && curl -s ${YANG_MODEL_INSTALL_SCRIPT} | TERM="xterm" bash -x  

FROM ubuntu:18.04

COPY --from=intermediate /hicn-root /hicn-root
COPY --from=intermediate /hicn-build/sysrepo/  /hicn-build/sysrepo/
COPY --from=intermediate /hicn-build/hicn  /hicn-build/hicn

RUN apt-get update && apt-get install -y curl libprotobuf-c-dev libev-dev libavl-dev libssh-dev
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update && apt-get install -y supervisor vpp libvppinfra vpp-plugin-core vpp-dev libhicn-dev

WORKDIR /

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
