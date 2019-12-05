#!/bin/bash
rm -r hicn-nso-new 2>/dev/null
rm -r hicn-nso-project-new 2> /dev/null
#cp /home/sc/hicn/utils/sysrepo-plugins/hicn-plugin/plugin/yang/model/hicn.yang  hicn-yang-model/
source nso-4.7/ncsrc 
ncs-make-package --netconf-ned hicn-yang-model-new hicn-nso-new
cd hicn-nso/src; make
cd ../..
ncs-setup --ned-package hicn-nso-new --dest hicn-nso-project-new
cd hicn-nso-project-new
ncs
ncs_cli -C -u admin
