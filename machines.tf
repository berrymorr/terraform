
locals {
  pool = "default"
  network = { name="default", bridge="virbr0" }
  vms = [
    { name="server-1", cores=4, mem=4096, ip="192.168.122.21", disks=[10] },
    { name="server-2", cores=4, mem=4096, ip="192.168.122.22", disks=[10,20] },
    { name="server-3", cores=4, mem=4096, ip="192.168.122.23", disks=[10,20] },
  ]
}
