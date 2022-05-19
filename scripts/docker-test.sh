
docker build -f ../Dockerfile . -t vswitch

docker network create net1 --subnet=10.1.0.0/16
docker network create net2 --subnet=10.2.0.0/16
docker network create net3 --subnet=10.3.0.0/16


docker run -dit --name host1 --hostname host1 --privileged --net net1 vswitch
docker run -dit --name host2 --hostname host2 --privileged --net net3 vswitch

docker run -dit --name router1 --hostname router1 --privileged --net net1 vswitch
docker network connect net2 router1
docker run -dit --name router2 --hostname router2 --privileged --net net2 vswitch 
docker network connect net3 router2

docker exec host1 /bin/bash -c "route add default gw 10.1.0.3; route del default gw 10.1.0.1"
docker exec host2 /bin/bash -c "route add default gw 10.3.0.3; route del default gw 10.3.0.1"

docker stop host1 host2 router1 router2
docker container rm host1 host2 router1 router2 
docker network remove net1 net2 net3
