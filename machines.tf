
locals {
  pool = "default"
  #source_image = "/root/CentOS-7-x86_64-GenericCloud.qcow2"
  source_image = "/root/almacloud8.qcow2"
  vms = [
    { name="server-1", cores=4, mem=4096, disks=[10], nets=[
      {name="default", br="virbr0", dev="eth0", ip="192.168.122.21", prfx="24", dns="192.168.122.1", gw="192.168.122.1"}
    ] },
    { name="server-2", cores=4, mem=4096, disks=[10], nets=[
      {name="default", br="virbr0", dev="eth0", ip="192.168.122.22", prfx="24", dns="192.168.122.1", gw="192.168.122.1"},
      {name="default", br="virbr0", dev="eth1", ip="192.168.144.44", prfx="24", dns="192.168.144.1", gw="192.168.144.1"},
    ] },
  ]
}
