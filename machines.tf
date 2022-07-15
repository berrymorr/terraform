
locals {
  virtual_machines = {
    "server-1" = { system_cores = 1, system_memory = 1024, ip="192.168.122.21", disk=20*1024*1024*1024 },
    "server-2" = { system_cores = 1, system_memory = 1024, ip="192.168.122.22", disk=10*1024*1024*1024 },
    "server-zalupa" = { system_cores = 2, system_memory = 10240, ip="192.168.122.122", disk=30*1024*1024*1024 },
  }
}
