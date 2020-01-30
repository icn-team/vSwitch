#!/bin/bash
# VAGRANT_DEFAULT_PROVIDER={libvirt, vmware, virtualbox}
export VAGRANT_DEFAULT_PROVIDER=$1
vagrant up
vagrant ssh -c "sudo bash /vagrant/bootstrap.sh"
vagrant ssh -c "sudo apt-get clean && sudo apt-get purge &&\
                sudo dd if=/dev/zero of=/EMPTY bs=1M &&\
                sudo rm -f /EMPTY &&\
                cat /dev/null > ~/.bash_history && history -c"
vagrant package --output hicn-vnf.box

