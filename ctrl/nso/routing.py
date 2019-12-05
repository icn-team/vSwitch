import ncs;

with ncs.maapi.single_write_trans('admin','python') as trans:
    root=ncs.maagic.get_root(trans)
    device=root.devices.device['hicn']
    inp=device.rpc.hcn__rpc_face_ip_add.face_ip_add.get_input()
    inp.lip4='-1'
    inp.lip6='2001::1'
    inp.rip4='-1'
    inp.rip6='2001::2'
    inp.swif=1 # This is the Idx
    device.rpc.hcn__rpc_face_ip_add.face_ip_add(inp)
    print("Face added successfully")


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


    inp=device.rpc.hcn__rpc_punting_add.punting_add.get_input()
    inp.ip4='-1'
    inp.ip6='b001::'
    inp.len=64
    inp.swif=1
    device.rpc.hcn__rpc_punting_add.punting_add(inp)
    print("Punting added successfully")
    trans.apply()
