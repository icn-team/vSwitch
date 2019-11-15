#!/bin/bash

/usr/bin/vpp -c /etc/vpp/startup.conf &>log.txt &
sleep 20
sysrepod -d -l 0 &
sleep 5
sysrepo-plugind -d -l 0 &
sleep 5
netopeer2-server -d -v 0 &
sleep 5
echo 'root:1' | chpasswd
trap "kill -9 $$" SIGHUP SIGINT SIGTERM SIGCHLD
wait
