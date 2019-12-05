#!/usr/bin/env python3

import datetime
import time
from influxdb import InfluxDBClient

rxp=open('/sys/class/net/eth0/statistics/rx_bytes','r')
txp=open('/sys/class/net/eth0/statistics/tx_bytes','r')


dbclient = InfluxDBClient('10.192.0.2', 30935, 'admin', 'admin', 'demo_light')

rxpv=rxp.read()
txpv=txp.read()
rxev=rxe.read()
txev=txe.read()
rxp.seek(0, 0)
txp.seek(0, 0)
rxe.seek(0, 0)
txe.seek(0, 0)

oldp=int(rxpv)+int(txpv)
olde=int(rxev)+int(txev)

while True:
  rxpv=rxp.read()
  txpv=txp.read()
  rxev=rxe.read()
  txev=txe.read()
  rxp.seek(0, 0)
  txp.seek(0, 0)
  rxe.seek(0, 0)
  txe.seek(0, 0)
  valp=(int(rxpv)+int(txpv)-oldp)*8
  vale=(int(rxev)+int(txev)-olde)*8
  oldp=int(rxpv)+int(txpv)
  olde=int(rxev)+int(txev)
  print('{valp}'.format(valp=valp))
  print('{vale}'.format(vale=vale))
  receiveTime=datetime.datetime.utcnow()
  label='en-privc'
  json_body = [
  {
    "measurement": label,
    "time": receiveTime,
     "fields": {
      "value": valp}
  }
  ]
  dbclient.write_points(json_body)

  label='en-enc'
  json_body = [
  {
    "measurement": label,
    "time": receiveTime,
     "fields": {
      "value": vale}
  }
  ]
  dbclient.write_points(json_body)
  time.sleep(1)
