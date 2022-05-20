#!/usr/bin/env bash


docker container stop host1 host2 vswitch1 vswitch2
docker container rm host1 host2 vswitch1 vswitch2
docker network remove net1 net2 net3

# Image
docker build -f ../Dockerfile . -t vswitch

# Networks
docker network create net1 --subnet=172.1.0.0/16
docker network create net2 --subnet=172.2.0.0/16
docker network create net3 --subnet=172.3.0.0/16

# Hosts
docker run -dit --name host1 --hostname host1 --privileged --net net1 vswitch
docker run -dit --name host2 --hostname host2 --privileged --net net3 vswitch

# swtiches
docker run -dit --name switch1 --hostname switch1 --privileged --net net1 vswitch
docker network connect net2 switch1

docker run -dit --name switch2 --hostname switch2 --privileged --net net2 vswitch
docker network connect net3 switch2

docker exec -it host1 /bin/bash -c "route add  default gw 172.1.0.3; route del  default gw 172.1.0.1; "
docker exec -it host2 /bin/bash -c "route add  default gw 172.3.0.3; route del  default gw 172.3.0.1; "
