## Instruction

To connect NSO to the netopeer2-server, first, it requires to write a NED package for the device. The procudeure to create NED package service for hicn is explaned in the following:

Place hicn.yang model in a folder called hicn-yang-model, and follow these steps:

- ncs-make-package --netconf-ned ./hicn-yang-model ./hicn-nso
- cd hicn-nso/src; make
- ncs-setup --ned-package ./hicn-nso --dest ./hicn-nso-project
- cd hicn-nso-project
- ncs
- ncs_cli -C -u admin
- configure
- devices authgroups group authhicn default-map remote-name user_name remote-password password
- devices device hicn address IP_device port 830 authgroup authhicn device-type netconf
- state admin-state unlocked
- commit
- ssh fetch-host-keys

At this point, we are able to connect to the remote device. To simplyfy a bash script is provided to create the package service.
