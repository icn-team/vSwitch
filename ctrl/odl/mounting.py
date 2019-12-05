#!/usr/bin/python
import socket
import requests
import datetime
import time
import argparse
import sys
import xml.etree.ElementTree as ET
import progressbar

from time import sleep
bar = progressbar.ProgressBar(maxval=20, \
    widgets=[progressbar.Bar('=', '[', ']'), ' ', progressbar.Percentage()])

barcount=1

# Parsing argument
parser = argparse.ArgumentParser(description='Mounting nodes to ODL')
parser.add_argument('-act', action="store",  dest='act',
                    help='Indicate your operation')
results = parser.parse_args()

SUCCESS = [200,201,202]

# Mount point names
nodes = ['host-eth', 'host-wifi', 'host-isp','host-en','host-enc','host-int','host-privc','host-pubc']

print('Mounting/Umounting nodes')
bar.start()
for node in nodes:
   response= None
   url = 'http://localhost:8181/restconf/config/network-topology:network-topology/topology/topology-netconf/node/'+str(node)
   tree = ET.parse('/hicn/cntrl/tnode.xml')
   root = tree.getroot()
   for elem in root:
      if(elem.tag=='{urn:TBD:params:xml:ns:yang:network-topology}node-id'):
         elem.text=str(node)
      if(elem.tag=='{urn:opendaylight:netconf-node-topology}schema-cache-directory'):
         elem.text=str(node)
      if(elem.tag=='{urn:opendaylight:netconf-node-topology}host'):
         elem.text=socket.gethostbyname(str(node))
   tree.write('/hicn/cntrl/node.xml')
   filename='/hicn/cntrl/node.xml'
   headers = {'content-type': 'application/xml','accept':'application/xml'}
   if str(results.act)=='del':
     response = requests.delete(url, auth=('admin', 'admin'),data=open(filename).read(),headers=headers)
   elif str(results.act)=='add':
     response = requests.put(url, auth=('admin', 'admin'),data=open(filename).read(),headers=headers)
   if response==None:
     print('usage: mount.py -del/add')
     break
   elif response.status_code in SUCCESS:
     bar.update(barcount+1)
     barcount=barcount+1
     sleep(0.1)
   else:
     print('operation failed'+str(node)+str(response))
bar.finish()
