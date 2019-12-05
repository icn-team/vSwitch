import ncs
import datetime
import time

###########################
# RPC call 
###########################

with ncs.maapi.single_write_trans('admin','python') as trans:
    root=ncs.maagic.get_root(trans)
    device=root.devices.device['hicn']

# Add Face

    inp=device.rpc.hcn__rpc_face_ip_add.face_ip_add.get_input()
    inp.lip4='-1'
    inp.lip6='3001::1'
    inp.rip4='-1'
    inp.rip6='6001::2'
    inp.swif=0
    device.rpc.hcn__rpc_face_ip_add.face_ip_add(inp)
    print("Face added successfully")


# Add route

    inp=device.rpc.hcn__rpc_route_nhops_add.route_nhops_add.get_input()
    inp.ip4='-1'
    inp.ip6='b001::'
    inp.len=64
    inp.face_ids0=0
    inp.face_ids1=0
    inp.face_ids2=0
    inp.face_ids3=0
    inp.face_ids4=0
    inp.face_ids5=0
    inp.face_ids6=0
    inp.n_faces=1
    device.rpc.hcn__rpc_route_nhops_add.route_nhops_add(inp)
    print("Route added successfully")

# Add punting

    inp=device.rpc.hcn__rpc_punting_add_ip.punting_add_ip.get_input()
    inp.ip4='-1'
    inp.ip6='b001::'
    inp.len=64
    inp.swif=0
    device.rpc.hcn__rpc_punting_add_ip.punting_add_ip(inp)
    print("Punting added successfully")
    trans.apply()



###########################
# Operational data (faces)
###########################


# Receive faces status 

with ncs.maapi.single_read_trans('admin','python') as trans:
        root=ncs.maagic.get_root(trans)
        device=root.devices.device["hicn"]
        for x in range(100):
            try:
                pc=device.live_status.hicn_state.faces.face[str(x)].drx_bytes
                print(pc)
            except:
                break
        print('finished')


# Receive routes status 

with ncs.maapi.single_read_trans('admin','python') as trans:
        root=ncs.maagic.get_root(trans)
        device=root.devices.device["hicn"]
        for x in range(100):
            try:
                pc=device.live_status.hicn_state.routes.route[str(x)].prefix
                print(pc)
            except:
                break
        print('finished')
