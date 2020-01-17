#!/bin/bash

echo "Configure VPP"
if [ -n "$DPDK" ]
then
    BLOCK="dpdk { $DPDK }"
fi

if [ ! -n "$NUM_BUFFER" ]
then
    NUM_BUFFER=16384
fi

if [ ! -n "$PIT_SIZE" ]
then
    PIT_SIZE=131072
fi

if [ ! -n "$CS_SIZE" ]
then
    CS_SIZE=4096
fi

if [ ! -n "$CS_RESERVED_APP" ]
then
    CS_RESERVED_APP=20
fi

eval sed -e "s/DPDK/\"$(echo $BLOCK)\"/g" -e "s/NUM_BUFFER/\"$(echo $NUM_BUFFER)\"/g" -e "s/PIT_SIZE/\"$(echo $PIT_SIZE)\"/g" -e "s/CS_SIZE/\"$(echo $CS_SIZE)\"/g" -e "s/CS_RESERVED_APP/\"$(echo $CS_RESERVED_APP)\"/g" /tmp/startup_template.conf > /etc/vpp/startup.conf


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
