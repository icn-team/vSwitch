FROM ubuntu:18.04

# Build hicn suite (from source for disabling punting)
WORKDIR /hicn
ENV SYSREPO_PLUGIN_DEB=hicn_sysrepo_plugin-19.04-36-release-Linux.deb
ENV SYSREPO_PLUGIN_URL=https://jenkins.fd.io/job/hicn-sysrepo-plugin-verify-master/59/artifact/scripts/build/${SYSREPO_PLUGIN_DEB}
ENV HICNLIGHT_PLUGIN_LIB=/usr/lib/x86_64-linux-gnu/sysrepo/plugins/libhicnlight.so

# Use bash shell
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get update && apt-get install -y curl
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update

# Install hicn-plugin

RUN apt-get install -y vpp libvppinfra vpp-plugin-core vpp-dev libparc libparc-dev python3-ply python python-ply
#hicn-plugin hicn-utils-memif libhicntransport-memif

# Install utils for hiperf
RUN  apt-get update && apt-get install -y iproute2 net-tools ethtool

# Install main packages
RUN apt-get install -y git cmake build-essential libpcre3-dev swig \
    libprotobuf-c-dev libev-dev libavl-dev protobuf-c-compiler libssl-dev \
    libssh-dev libcurl4-openssl-dev libasio-dev --no-install-recommends openssh-server dumb-init

  # Install hicn dependencies                                                                   \
RUN rm -rf /var/lib/apt/lists/* \
  ###############################################                                               \
  # Build libyang from source                                                                   \
  ################################################                                              \
  && git clone https://github.com/CESNET/libyang                                                \
  && mkdir -p libyang/build                                                                     \
  && pushd libyang/build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j 4 install && popd   \
  ########################################################################################      \
  # Build sysrepo from source                                                                   \
  ########################################################################################      \
  && git clone https://github.com/sysrepo/sysrepo.git                                           \
  && mkdir -p sysrepo/build                                                                     \
  && pushd sysrepo/build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..     \
  && make -j 4 install && popd    \
  ############################################################                                  \
  # Build libnetconf2 from source                                                               \
  ############################################################                                  \
  && git clone https://github.com/CESNET/libnetconf2                                            \
  && mkdir -p libnetconf2/build                                                                 \
  && pushd libnetconf2/build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j4 install && popd\
  ############################################################                                  \
  # Build Netopeer                                                                              \
  ############################################################                                  \
  && git clone https://github.com/CESNET/Netopeer2                                              \
  && mkdir -p Netopeer2/server/build                                                            \
  && pushd Netopeer2/server/build && cmake -DCMAKE_INSTALL_PREFIX=/usr ..                       \
  && make -j 4 install && popd                                                                  \
  ############################################################                                  \
  # Build libmemif                                                                              \
  ############################################################                                  \
  && git clone https://gerrit.fd.io/r/vpp                                                       \
  && pushd vpp && git checkout origin/stable/1904                                               \
  && pushd extras/libmemif                                                                      \
  && mkdir build && pushd build                                                                 \
  && cmake ../ -DCMAKE_INSTALL_PREFIX=/usr                                                      \
  && make -j4 install && popd && popd && popd                                                   \
  #####################################################################                         \
  && git clone https://github.com/FDio/hicn.git                                                 \
  && sed -i 's/#define HICN_PARAM_PIT_ENTRY_PHOPS_MAX 20/#define HICN_PARAM_PIT_ENTRY_PHOPS_MAX 260/g' hicn/hicn-plugin/src/params.h\
  && mkdir build && pushd build                                                                 \
  && cmake ../hicn -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_HICNPLUGIN=on -DBUILD_APPS=On            \
  && make -j4 install && popd                                                                   \
  #####################################################################                         \
  # Download sysrepo plugin                                                                     \
  && curl -OL ${SYSREPO_PLUGIN_URL}                                                             \
#   Install sysrepo hicn plugin                                                                 \
  && apt-get install -y ./${SYSREPO_PLUGIN_DEB} --no-install-recommends                         \
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
COPY init.sh .

WORKDIR /
