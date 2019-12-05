FROM ubuntu:18.04

WORKDIR /hicn
ENV ODL_VERSION=opendaylight-0.9.2.zip
ENV ODL_URL=https://nexus.opendaylight.org/content/repositories/public/org/opendaylight/integration/opendaylight/0.9.2/${ODL_VERSION}

# Use bash shell
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y curl
RUN curl -OL ${ODL_URL} &&  apt-get install unzip &&  unzip ${ODL_VERSION} && rm -r ${ODL_VERSION}
RUN apt-get update && apt-get install openjdk-8-jre -y

RUN apt-get install python3.6 -y
RUN apt-get install python3 -y && apt install python-pip -y && apt install python3-pip -y
RUN pip3 install pyyaml && apt install python3-pyparsing -y && pip3 install janus &&  apt install python3-lockfile -y && apt install python3-daemon -y && pip3 install autobahn
RUN pip3 install requests && pip3 install avro-python3 && pip3 install kafka && pip install influxdb && pip3 install aiomysql && pip3 install aiopg && apt install apache2 -y && pip install progressbar

RUN mkdir cntrl

COPY face.xml  facing.py  mounting.py  punting.py  punt.xml  route.xml  routing.py  telemetring.py  tface.xml  tnode.xml  tpunt.xml  troute.xml  mark.txt setup.sh cntrl/

WORKDIR /hicn
