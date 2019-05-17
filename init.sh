#!/bin/bash

if [ $HOSTNAME = "host-vs1" ]
   then
     ip addr flush dev eth1
     ip addr flush dev eth2
     ip addr flush dev eth3
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth2 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth3 tx off rx off ufo off gso off gro off tso off
elif  [ $HOSTNAME = "host-vs2" ]
   then
     ip addr flush dev eth1
     ip addr flush dev eth2
     ip addr flush dev eth3
     ip addr flush dev eth4
     ip addr flush dev eth5
     ip addr flush dev eth6
     ip addr flush dev eth7
     ip addr flush dev eth8
     ip addr flush dev eth9
     ip addr flush dev eth10
     ip addr flush dev eth11
     ethtool -K eth1 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth2 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth3 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth4 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth5 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth6 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth7 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth8 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth9 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth10 tx off rx off ufo off gso off gro off tso off
     ethtool -K eth11 tx off rx off ufo off gso off gro off tso off
fi
/usr/bin/vpp -c /etc/hicn/super_startup.conf &>log.txt &
sleep 20
sysrepod -d -l 0 &
sysrepo-plugind -d -l 0 &
netopeer2-server -d -v 0 &
trap "kill -9 $$" SIGHUP SIGINT SIGTERM SIGCHLD
wait
