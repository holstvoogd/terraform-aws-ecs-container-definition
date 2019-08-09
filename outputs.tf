output "container_definition" {
  value = jsonencode(
    {
      name              = var.name
      image             = var.image
      hostname          = var.hostname
      cpu               = var.cpu
      memory            = var.memory
      memoryReservation = var.memory_reservation
      essential         = var.essential ? true : false
      entryPoint        = compact(split(" ", var.entrypoint))
      command           = compact(split(" ", var.command))
      links             = var.links
      portMappings      = var.port_mappings
      mountPoints       = [for mount in var.mount_points : { "containerPath" = mount.path, "sourceVolume" = mount.volume }]
      ulimits           = [for name, limit in var.ulimits : { "name" = name, "softLimit" = limit }]
      environment       = [for name, value in var.environment_vars : { "name" = name, "value" = value }]
      logConfiguration = {
        logDriver = var.log_driver
        options   = var.log_driver_options
      }
      tags        = {}
      volumesFrom = []
    }
  )
}

output "name" {
  value = var.name
}
