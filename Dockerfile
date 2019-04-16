FROM ubuntu:18.04

# Build hicn suite (from source for disabling punting)
WORKDIR /hicn
ENV SYSREPO_PLUGIN_URL=https://jenkins.fd.io/job/hicn-sysrepo-plugin-verify-master/lastSuccessfulBuild/artifact/scripts/build/hicn_sysrepo_plugin-19.01-176-release-Linux.deb
ENV HICNLIGHT_PLUGIN_LIB=/usr/lib/x86_64-linux-gnu/sysrepo/plugins/libhicnlight.so

# Use bash shell
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y curl
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash

# Install main packages
RUN apt-get install -y git cmake build-essential libpcre3-dev swig \
    libprotobuf-c-dev libev-dev libavl-dev protobuf-c-compiler libssl-dev \
    libssh-dev libcurl4-openssl-dev libasio-dev hicn-plugin --no-install-recommends ;\
  # Install hicn dependencies                                                                   \
  rm -rf /var/lib/apt/lists/* \
  ###############################################                                               \
  # Build libyang from source                                                                   \
  ################################################                                              \
  && git clone https://github.com/CESNET/libyang \
  && mkdir -p libyang/build \
  && pushd libyang/build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j 4 install && popd \
  ########################################################################################      \
  # Build sysrepo from source                                                                   \
  ########################################################################################      \
  && git clone https://github.com/sysrepo/sysrepo.git \
  && mkdir -p sysrepo/build \
  && pushd sysrepo/build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. \
  && make -j 4 install && popd \
  ############################################################                                  \
  # Build libnetconf2 from source                                                               \
  ############################################################                                  \
  && git clone https://github.com/CESNET/libnetconf2 \
  && mkdir -p libnetconf2/build \
  && pushd libnetconf2/build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 install && popd\
  ############################################################                                  \
  # Build Netopeer                                                                              \
  ############################################################                                  \
  && git clone https://github.com/CESNET/Netopeer2 \
  && mkdir -p Netopeer2/server/build \
  && pushd Netopeer2/server/build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. \
  && make -j 4 install && popd \
  #####################################################################                         \
  # Download sysrepo plugin                                                                     \
  && curl -OL ${SYSREPO_PLUGIN_URL} \
  # Install sysrepo hicn plugin                                                                 \
  && apt-get install -y ./hicn_sysrepo_plugin-19.01-176-release-Linux.deb --no-install-recommends \
  ###################################################                                           \
  # Clean up                                                                                    \
  ###################################################                                           \
  && apt-get remove -y git cmake build-essential libasio-dev \
                      libcurl4-openssl-dev libev-dev libpcre3-dev libprotobuf-c-dev \
                      libssh-dev libssl-dev protobuf-c-compiler swig \
  && apt-get install libprotobuf-c1 libev4 libssh-4\
  && rm -rf /var/lib/apt/lists/* \
  && apt-get autoremove -y \
  && apt-get clean && rm -r /hicn\
  ####################################################
  # Delete library for hicn-plugin
  ####################################################
  && rm ${HICNLIGHT_PLUGIN_LIB}

#################################
# Install hicn module in sysrepo
##################################
WORKDIR /tmp

ENV YANG_MODEL_INSTALL_SCRIPT=https://raw.githubusercontent.com/icn-team/vSwitch/master/yang_fetch.sh
ENV YANG_MODEL_LIST=https://raw.githubusercontent.com/icn-team/vSwitch/master/yang_list.txt
RUN curl -OL ${YANG_MODEL_LIST} && curl -s ${YANG_MODEL_INSTALL_SCRIPT} | TERM="xterm" bash -x  

WORKDIR /