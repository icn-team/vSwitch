import ncs
import datetime
import time
from influxdb import InfluxDBClient


# Set up a client for InfluxDB
dbclient = InfluxDBClient('127.0.0.1', 8086, 'admin', 'masmas', 'demo')
collection = ['pps', 'pic', 'pdc','pfcc','pnpc','pec1','cec1','clc','pdnb','ia','ir','pec2','cec2','centc']

# Initialize state data
pps_old=0
pic_old=0
pdc_old=0
pfcc_old=0
pnpc_old=0
pec1_old=0
cec1_old=0
clc_old=0
pdnb_old=0
ia_old=0
ir_old=0
pec2_old=0
cec2_old=0
centc_old=0

while True:
    print("<------Reading operational data------>")
    with ncs.maapi.single_read_trans('admin','python') as trans:
        root=ncs.maagic.get_root(trans)
        device=root.devices.device["hicn"]
        device.rpc.hcn__rpc_node_stat_get.node_stat_get()
        receiveTime=datetime.datetime.utcnow()
        pps = device.live_status.hicn_state.states.pkts_processed
        pic = device.live_status.hicn_state.states.pkts_interest_count
        pdc = device.live_status.hicn_state.states.pkts_data_count
        pfcc = device.live_status.hicn_state.states.pkts_from_cache_count
        pnpc = device.live_status.hicn_state.states.pkts_no_pit_count
        pec1 = device.live_status.hicn_state.states.pit_expired_count
        cec1 = device.live_status.hicn_state.states.cs_expired_count
        clc = device.live_status.hicn_state.states.cs_lru_count
        pdnb = device.live_status.hicn_state.states.pkts_drop_no_buf
        ia = device.live_status.hicn_state.states.interests_aggregated
        ir = device.live_status.hicn_state.states.interests_retx
        pec2 = device.live_status.hicn_state.states.pit_entries_count
        cec2 = device.live_status.hicn_state.states.cs_entries_count
        centc = device.live_status.hicn_state.states.cs_entries_ntw_count
        for rxdata in collection:
            if rxdata == 'pps':
                val=pps-pps_old
            elif rxdata == 'pic':
                val=pic-pic_old
            elif rxdata == 'pdc':
                val=pdc-pdc_old
            elif rxdata == 'pfcc':
                val=pfcc-pfcc_old
            elif rxdata == 'pnpc':
                val=pnpc-pnpc_old
            elif rxdata == 'pec1':
                val=pec1-pec1_old
            elif rxdata == 'cec1':
                val=cec1-cec1_old
            elif rxdata == 'clc':
                val=clc-clc_old
            elif rxdata == 'pdnb':
                val=pdnb-pdnb_old
            elif rxdata == 'ia':
                val=ia-ia_old
            elif rxdata == 'ir':
                val=ir-ir_old
            elif rxdata == 'pec2':
                val=pec2-pec2_old
            elif rxdata == 'cec2':
                val=cec2-cec2_old
            elif rxdata == 'centc':
                val=centc-centc_old
            print(val)
            json_body = [
                        {
                            "measurement": rxdata,
                            "time": receiveTime,
                            "fields": {
                                "value": val
                            }
                        }
                    ]
            dbclient.write_points(json_body)
            print("Finished writing to InfluxDB "+str(rxdata))
        pps_old=pps
        pic_old=pic
        pdc_old=pdc
        pfcc_old=pfcc
        pnpc_old=pnpc
        pec1_old=pec1
        cec1_old=cec1
        clc_old=clc
        pdnb_old=pdnb
        ia_old=ia
        ir_old=ir
        pec2_old=pec2
        cec2_old=cec2
        centc_old=centc
        time.sleep(1)