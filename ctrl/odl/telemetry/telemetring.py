#!/usr/bin/python

import requests
import datetime
import time
import argparse
import sys
import xml.etree.ElementTree as ET
from influxdb import InfluxDBClient

TX=0
RX=1
TXO=2
RXO=3
itx=0
irx=0
drx=0
dtx=0
faceid=0
flag=0

SUCCESS = [200,201,202]

# Mount point names
nodes = ['host-eth', 'host-wifi', 'host-isp','host-en','host-enc','host-int','host-privc','host-pubc']


# This dic maps node name to tx, rx

link={'eth-en':(0,0),'wifi-en':(0,0),'isp-int':(0,0),'en-enc':(0,0),'en-privc':(0,0), 'en-asa':(0,0), 'int-pubc':(0,0), 'int-asa':(0,0)}
old={'eth-en':(0,0),'wifi-en':(0,0),'isp-int':(0,0),'en-enc':(0,0),'en-privc':(0,0), 'en-asa':(0,0), 'int-pubc':(0,0), 'int-asa':(0,0)}

# Set up a client for InfluxDB
dbclient = InfluxDBClient('10.100.95.111', 8086, 'admin', 'masmas', 'demo_clus')

while True:
   for node in nodes:
      response=None
      url=None
      url = 'http://localhost:8181/restconf/operational/network-topology:network-topology/topology/topology-netconf/node/'+str(node)+'/yang-ext:mount'
      headers = {'content-type': 'application/xml','accept':'application/xml'}
      response = requests.get(url, auth=('admin', 'admin'),headers=headers)
      if response.status_code in SUCCESS:
         receiveTime=datetime.datetime.utcnow()
         root = ET.fromstring(response.text)
         for hicn in root.findall("./{urn:sysrepo:hicn}hicn-state"):
            for faces in hicn.findall('{urn:sysrepo:hicn}faces'):
               for face in faces:
                  for elem in face:
                     if elem.tag=='{urn:sysrepo:hicn}faceid':
                           faceid=int(elem.text)
                     if elem.tag=='{urn:sysrepo:hicn}drx_bytes':
                           drx=int(elem.text)
                     if elem.tag=='{urn:sysrepo:hicn}dtx_bytes':
                           dtx=int(elem.text)
                     if elem.tag=='{urn:sysrepo:hicn}irx_bytes':
                           irx=int(elem.text)
                     if elem.tag=='{urn:sysrepo:hicn}itx_bytes':
                           itx=int(elem.text)
                  if node=='host-eth' and faceid==0:
                     link['eth-en']=((dtx+itx)-old['eth-en'][TX],(drx+irx)-old['eth-en'][RX])
                     old['eth-en']=((dtx+itx),(drx+irx))
                     val=(link['eth-en'][TX]+link['eth-en'][RX])*8
                     label='eth-en'
                     flag=1

                  if node=='host-wifi' and faceid==0:
                     link['wifi-en']=((dtx+itx)-old['wifi-en'][TX],(drx+irx)-old['wifi-en'][RX])
                     old['wifi-en']=((dtx+itx),(drx+irx))
                     val=(link['wifi-en'][TX]+link['wifi-en'][RX])*8
                     label='wifi-en'
                     flag=1

                  if node=='host-isp' and faceid==0:
                     link['isp-int']=((dtx+itx)-old['isp-int'][TX],(drx+irx)-old['isp-int'][RX])
                     old['isp-int']=((dtx+itx),(drx+irx))
                     val=(link['isp-int'][TX]+link['isp-int'][RX])*8
                     label='isp-int'
                     flag=1

                  if node=='host-en' and faceid==3:
                     link['en-enc']=((dtx+itx)-old['en-enc'][TX],(drx+irx)-old['en-enc'][RX])
                     old['en-enc']=((dtx+itx),(drx+irx))
                     val=(link['en-enc'][TX]+link['en-enc'][RX])*8
                     label='en-enc'
                     flag=1

                  if node=='host-en' and faceid==4:
                     link['en-privc']=((dtx+itx)-old['en-privc'][TX],(drx+irx)-old['en-privc'][RX])
                     old['en-privc']=((dtx+itx),(drx+irx))
                     val=(link['en-privc'][TX]+link['en-privc'][RX])*8
                     label='en-privc'
                     flag=1

                  if node=='host-en' and faceid==0:
                     link['en-asa']=((dtx+itx)-old['en-asa'][TX],(drx+irx)-old['en-asa'][RX])
                     old['en-asa']=((dtx+itx),(drx+irx))
                     val=(link['en-asa'][TX]+link['en-asa'][RX])*8
                     label='en-asa'
                     flag=1

                  if node=='host-int' and faceid==1:
                     link['int-pubc']=((dtx+itx)-old['int-pubc'][TX],(drx+irx)-old['int-pubc'][RX])
                     old['int-pubc']=((dtx+itx),(drx+irx))
                     val=(link['int-pubc'][TX]+link['int-pubc'][RX])*8
                     label='int-pubc'
                     flag=1

                  if node=='host-int' and faceid==2:
                     link['int-asa']=((dtx+itx)-old['int-asa'][TX],(drx+irx)-old['int-asa'][RX])
                     old['int-asa']=((dtx+itx),(drx+irx))
                     val=(link['int-asa'][TX]+link['int-asa'][RX])*8
                     label='int-asa'
                     flag=1
                  if flag==1:
                     json_body = [
                            {
                                "measurement": label,
                                "time": receiveTime,
                                "fields": {
                                    "value": val
                                }
                            }
                     ]

                     try:
                        dbclient.write_points(json_body)
                        print("Finished writing to InfluxDB "+str(label))
                        flag=0
                     except Exception:
                        print("<<<<<Error writing to InfluxDB>>>>")
                        flag=0
      else:
         print('Error connecting to node: '+str(node)+str(response.status_code))

   time.sleep(1)
