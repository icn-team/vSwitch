#!/bin/bash

for i in $*
do
    ip addr flush dev $i
    ethtool -K $i tx off rx off ufo off gso off gro off tso off
done

/usr/bin/vpp -c /etc/hicn/super_startup.conf &>log.txt &
sleep 20
sysrepod -d -l 0 &
sysrepo-plugind -d -l 0 &
netopeer2-server -d -v 0 &
trap "kill -9 $$" SIGHUP SIGINT SIGTERM SIGCHLD
wait
