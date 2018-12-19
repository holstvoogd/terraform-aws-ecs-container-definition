variable "name" {
  description = "Name of the service."
}

variable "image" {
  description = "URL to the service image. Currently only Docker Hub an ECR are supported."
}

variable "cpu" {
  description = "Number of CPU units to assign to this task."
}

variable "memory" {
  description = "Memory in MegaBytes to assign to this task."
}

variable "memory_reservation" {
  description = "Memory in MegaBytes to reserve for this task."
}

variable "log_driver" {
  default = "awslogs"
}

variable "log_driver_options" {
  type = "map"

  default = {
    "awslogs-group"         = "common-log-group"
    "awslogs-region"        = "eu-west-1"
    "awslogs-stream-prefix" = "container"
  }
}

variable "port_mappings" {
  type = "list"

  default = [
    {
      "hostPort"      = "__NOT_DEFINED__"
      "containerPort" = "__NOT_DEFINED__"
    },
  ]
}

variable "mount_points" {
  type    = "list"
  default = []
}

variable "links" {
  type    = "list"
  default = []
}

variable "essential" {
  default = true
}

variable "entrypoint" {
  default = ""
}

variable "hostname" {
  default = ""
}

variable "command" {
  default     = ""
  description = "The command that needs to run at startup of the task."
}

variable "ulimits" {
  type    = "map"
  default = {}
}

variable "environment_vars" {
  type    = "map"
  default = {}
}
