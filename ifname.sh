#!/bin/bash

if [ $HOSTNAME = "host-eth" ]
   then
     ip addr flush dev eth1
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off 
     sed -i -e 's/main-core.*/main-core 1/' /etc/vpp/super_startup.conf
elif  [ $HOSTNAME = "host-wifi" ]
   then
     ip addr flush dev eth1
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     sed -i -e 's/main-core.*/main-core 2/' /etc/vpp/super_startup.conf
elif  [ $HOSTNAME = "host-isp" ]
   then
     ip addr flush dev eth1
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     sed -i -e 's/main-core.*/main-core 3/' /etc/vpp/super_startup.conf
elif  [ $HOSTNAME = "host-en" ]
   then
     ip addr flush dev eth1
     ip addr flush dev eth2
     ip addr flush dev eth3
     ip addr flush dev eth4
     ip addr flush dev eth5
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth2 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth3 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth4 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth5 tx off rx off ufo off gso off gro off tso off
     sed -i -e 's/main-core.*/main-core 4/' /etc/vpp/super_startup.conf
elif  [ $HOSTNAME = "host-enc" ]
   then
     ip addr flush dev eth1
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     sed -i -e 's/main-core.*/main-core 5/' /etc/vpp/super_startup.conf
elif  [ $HOSTNAME = "host-privc" ]
   then
     ip addr flush dev eth1
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     sed -i -e 's/main-core.*/main-core 6/' /etc/vpp/super_startup.conf
elif  [ $HOSTNAME = "host-pubc" ]
   then
     ip addr flush dev eth1
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     sed -i -e 's/main-core.*/main-core 7/' /etc/vpp/super_startup.conf
elif  [ $HOSTNAME = "host-asa" ]
   then
     ip addr flush dev eth1
     ip addr flush dev eth2
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth2 tx off rx off ufo off gso off gro off tso off
     sed -i -e 's/main-core.*/main-core 8/' /etc/vpp/super_startup.conf
elif  [ $HOSTNAME = "host-int" ]
   then
     ip addr flush dev eth1
     ip addr flush dev eth2
     ip addr flush dev eth3
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth2 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth3 tx off rx off ufo off gso off gro off tso off
     sed -i -e 's/main-core.*/main-core 9/' /etc/vpp/super_startup.conf
fi	
