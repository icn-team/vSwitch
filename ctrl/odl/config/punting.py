#!/usr/bin/python

import requests
import xml.etree.ElementTree as ET
import progressbar

from time import sleep
bar = progressbar.ProgressBar(maxval=50, \
    widgets=[progressbar.Bar('=', '[', ']'), ' ', progressbar.Percentage()])

barcount=1



# Mount point names
nodes = ['host-eth', 'host-wifi', 'host-isp','host-en','host-enc','host-int','host-privc','host-pubc']

SUCCESS = [200,201,202]

print("Applying Punting to the network")
bar.start()
for node in nodes:
      response=None
      url=None
      tree = ET.parse('/hicn/cntrl/punt.xml')
      root = tree.getroot()
      for puntes in root:
         for punt in puntes:
                 if punt.tag=='ip6':
                     ip6=punt.text
                 if punt.tag=='len':
                     lent=punt.text
                 if punt.tag=='swif':
                     swif=punt.text
         if puntes.tag==str(node):
            tree = ET.parse('/hicn/cntrl/tpunt.xml')
            troot = tree.getroot()
            for elem in troot:
               if elem.tag=='{urn:sysrepo:hicn}ip6':
                   elem.text=ip6
               if elem.tag=='{urn:sysrepo:hicn}len':
                   elem.text=lent
               if elem.tag=='{urn:sysrepo:hicn}swif':
                   elem.text=swif
            tree.write('/hicn/cntrl/apunt.xml')
            filename='/hicn/cntrl/apunt.xml'
            url = 'http://localhost:8181/restconf/operations/network-topology:network-topology/topology/topology-netconf/node/'+str(node)+'/yang-ext:mount/hicn:punting-add'
            headers = {'content-type': 'application/xml','accept':'application/xml'}
            response = requests.post(url, auth=('admin', 'admin'),data=open(filename).read(),headers=headers)
            if response.status_code in SUCCESS:
               bar.update(barcount+1)
               barcount=barcount+1
               sleep(0.1)
            else:
               print('operation failed'+str(node)+response.text)
bar.finish()
