terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}




resource "libvirt_volume" "os_image" {
  name   = "os_image"
  source = "/root/govno/CentOS-7-x86_64-GenericCloud.qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = local.virtual_machines
  name      = "${each.key}.iso"
  pool      = "default" # List storage pools using virsh pool-list
  user_data = templatefile("${path.module}/cloud_init.tftpl", {fqdn = each.key, ip = each.value.ip})
}

resource "libvirt_volume" "volume" {
  for_each       = local.virtual_machines
  name           = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.os_image.id
  size           = each.value.disk
}

resource "libvirt_domain" "domain" {
  for_each = local.virtual_machines
  name     = each.key
  memory   = each.value.system_memory
  vcpu     = each.value.system_cores

  disk {
    volume_id = libvirt_volume.volume[each.key].id
  }

  network_interface {
    network_name   = "default" # List networks with virsh net-list
    bridge         = "virbr0"
    addresses      = [each.value.ip]
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

}

#########################################################################
#output "instance_ips" {
#  value = libvirt_domain.domain.server-1.network_interface.0.addresses
#}
