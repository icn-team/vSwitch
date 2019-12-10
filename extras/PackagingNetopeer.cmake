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

# Generate DEB / RPM packages

######################
# Packages section
######################

set(netopeer2-server_DESCRIPTION
  "netopeer2 provides a NETCONF server and a CLI to connect the NETCONF server."
  CACHE STRING "Description for deb/rpm package."
)

set(netopeer2-server_DEB_DEPENDENCIES
   "libyang (>= 0.16-r2-1), libnetconf2 (>= 0.12-r1), sysrepo (>= 0.7.7)"
   CACHE STRING "Dependencies for deb/rpm package."
)

set(netopeer2-server_RPM_DEPENDENCIES
   "libyang (>= 0.16-r3-1), libnetconf2 (>= 0.12-r1), sysrepo (>= 0.7.7)"
   CACHE STRING "Dependencies for deb/rpm package."
)

set(netopeer2-cli_DESCRIPTION
  "netopeer2 provides a NETCONF server and a CLI to connect the NETCONF server."
  CACHE STRING "Description for deb/rpm package."
)

set(netopeer2-cli_DEB_DEPENDENCIES
   "libyang (>= 0.16-r2-1), libnetconf2 (>= 0.12-r1), sysrepo (>= 0.7.7)"
   CACHE STRING "Dependencies for deb/rpm package."
)

set(netopeer2-cli_RPM_DEPENDENCIES
   "libyang (>= 0.16-r3-1), libnetconf2 (>= 0.12-r1), sysrepo (>= 0.7.7)"
   CACHE STRING "Dependencies for deb/rpm package."
)