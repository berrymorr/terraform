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


locals {
  disks_flat = merge([for vm in local.vms : {for index, disk_size in vm.disks : ("${vm.name}_${index}") => disk_size}]...)
  disks_dynamic = { for vm in local.vms : (vm.name) => [ for index,disk in vm.disks : "${vm.name}_${index}" ] }
}


resource "libvirt_volume" "os_image" {
  name   = "os_image"
  #source = "/root/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "/root/almacloud8.qcow2"
  pool = local.pool
}


resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = { for vm in local.vms : (vm.name) => vm }
  name      = "${each.value.name}.iso"
  pool      = local.pool
  user_data = templatefile("${path.module}/cloud_init.tftpl", {fqdn = each.value.name, ip = each.value.ip})
}


resource "libvirt_volume" "volume" {
  for_each       = local.disks_flat
  name           = "${each.key}.qcow2"
  base_volume_id = regex("[0-9]+$",each.key) == "0" ? libvirt_volume.os_image.id : null
  size           = each.value*1024*1024*1024
  pool           = local.pool
}


resource "libvirt_domain" "domain" {
  for_each = { for vm in local.vms : (vm.name) => vm }
  name     = each.value.name
  memory   = each.value.mem
  vcpu     = each.value.cores

  dynamic "disk" {
    for_each = local.disks_dynamic[each.value.name]
    content {
      volume_id = libvirt_volume.volume[disk.value].id
    }
  }

  network_interface {
    network_name   = local.network.name
    bridge         = local.network.bridge
    addresses      = [each.value.ip]
    wait_for_lease = false
  }

  cloudinit = libvirt_cloudinit_disk.commoninit["${each.value.name}"].id

}

#########################################################################
#output "instance_ips" {
#  value = libvirt_domain.domain.server-1.network_interface.0.addresses
#}
