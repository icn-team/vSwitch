# Copyright (c) 2017-2019 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#!/bin/bash
# Install vpp
apt-get update && apt-get install -y curl
curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
apt-get update && apt-get install -y hicn-plugin hicn-plugin-dev vpp libvppinfra \
    vpp-plugin-core vpp-dev libparc libparc-dev python3-ply python python-ply

# Install main packages
apt-get install -y git cmake build-essential libpcre3-dev swig \
  libprotobuf-c-dev libev-dev libavl-dev protobuf-c-compiler libssl-dev \
  libssh-dev libcurl4-openssl-dev libasio-dev libconfig-dev --no-install-recommends openssh-server

git clone https://github.com/CESNET/libyang.git -b devel --depth 1
cp Packaging.cmake PackagingLibYang.cmake libyang/CMakeModules/
cd libyang; git apply ../libyang.diff
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE:String="Release" \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make package
mv *.deb ../../deb
make install 
cd ../..

git clone  https://github.com/sysrepo/sysrepo.git -b devel --depth 1
cp Packaging.cmake PackagingSysRepo.cmake sysrepo/CMakeModules/
cd sysrepo; git apply ../sysrepo.diff
mkdir -p build
cd build
cmake -D CMAKE_BUILD_TYPE:String="Release" \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DBUILD_EXAMPLES:BOOL=FALSE \
      -DGEN_LANGUAGE_BINDINGS=OFF ..
make package
mv *.deb ../../deb
make install
cd ../..

git clone https://github.com/CESNET/libnetconf2.git -b devel  --depth 1
cp Packaging.cmake PackagingLibNetconf.cmake libnetconf2/CMakeModules/
cd libnetconf2; git apply ../libnetconf2.diff
mkdir -p build
cd build
cmake -D CMAKE_BUILD_TYPE:String="Release" \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr -DENABLE_BUILD_TESTS=OFF .. 
make package
mv *.deb ../../deb
make install
cd ../../

git clone https://github.com/CESNET/Netopeer2.git -b devel-server --depth 1
cp Packaging.cmake PackagingNetopeer.cmake Netopeer2/CMakeModules/
cd Netopeer2; git apply ../netopeer2.diff
mkdir -p build-server
cd build-server
cmake -DCMAKE_BUILD_TYPE:String="Release" -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DENABLE_BUILD_TESTS=OFF ../server
make package
mv *.deb ../../deb
cd ..
mkdir -p build-cli
cd build-cli      
cmake -DCMAKE_BUILD_TYPE:String="Release" -DCMAKE_INSTALL_PREFIX:PATH=/usr ../cli
make package
mv *.deb ../../deb
cd ../../
