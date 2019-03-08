data "template_file" "_log_configuration" {
  count = "${var.log_driver == "__NOT_DEFINED__" ? 0 : 1}"

  template = <<JSON
{
  $${ jsonencode("logDriver") } : $${ jsonencode(log_driver) },
    $${ jsonencode("options") } : {
      $${ log_driver_options }
    }
}
JSON

  vars {
    log_driver         = "${var.log_driver}"
    log_driver_options = "${join(",\n", data.template_file._log_driver_options.*.rendered)}"
  }
}

data "template_file" "_log_driver_options" {
  count = "${ length(keys(var.log_driver_options)) }"

  template = <<JSON
$${ jsonencode(key) }: $${ jsonencode(value)}
JSON

  vars {
    key   = "${ element(keys(var.log_driver_options), count.index) }"
    value = "${ lookup(var.log_driver_options, element(keys(var.log_driver_options), count.index)) }"
  }
}

data "template_file" "_port_mappings" {
  template = <<JSON
$${val}
JSON

  vars {
    val = "${join(",\n", data.template_file._port_mapping.*.rendered)}"
  }
}

data "template_file" "_port_mapping" {
  count = "${ lookup(var.port_mappings[0], "containerPort") == "__NOT_DEFINED__" ? 0 : length(var.port_mappings) }"

  template = <<JSON
{
$${join(",\n",
  list(
  "$${ jsonencode("hostPort") }: $${host_port}",
  "$${jsonencode("containerPort")}: $${container_port}",
  "$${ jsonencode("protocol") }: $${jsonencode(protocol)}"
  )
)}
}
JSON

  vars {
    host_port      = "${ lookup(var.port_mappings[0], "hostPort", "0") }"
    container_port = "${ lookup(var.port_mappings[0], "containerPort") }"
    protocol       = "${ lookup(var.port_mappings[0], "protocol", "tcp") }"
  }
}

data "template_file" "_mount_points" {
  count = "${length(var.mount_points)}"

  template = <<JSON
{
$${join(",\n",
    list(
      "$${ jsonencode("containerPath") }: $${jsonencode(path)}",
      "$${ jsonencode("sourceVolume") }:  $${jsonencode(volume)}"
    )
)}
}
JSON

  vars {
    path   = "${ lookup(var.mount_points[count.index], "path") }"
    volume = "${ lookup(var.mount_points[count.index], "volume") }"
  }
}

data "template_file" "_ulimit" {
  count = "${length(keys(var.ulimits))}"

  template = <<JSON
{
$${join(",\n",
  compact(
    list(
    var_name == "__NOT_DEFINED__" ? "" : "$${ jsonencode("name") }: $${ jsonencode(var_name)}",
    var_value == "__NOT_DEFINED__" ? "" : "$${ jsonencode("softLimit") }: $${ var_value }",
    var_value == "__NOT_DEFINED__" ? "" : "$${ jsonencode("hardLimit") }: $${ var_value }"
    )
  )
)}
}
JSON

  vars {
    var_name  = "${ element(sort(keys(var.ulimits)), count.index) }"
    var_value = "${ lookup(var.ulimits, element(sort(keys(var.ulimits)), count.index), "") }"
  }
}

data "template_file" "_environment_var" {
  count = "${length(keys(var.environment_vars))}"

  template = <<JSON
{
$${join(",\n",
  compact(
    list(
      "$${ jsonencode("name") }: $${ jsonencode(var_name)}",
      "$${ jsonencode("value") }: $${ jsonencode(var_value)}"
    )
  )
)}
}
JSON

  vars {
    var_name  = "${ element(keys(var.environment_vars), count.index) }"
    var_value = "${  lookup(var.environment_vars, element(keys(var.environment_vars), count.index), "") }"
  }
}

data "template_file" "_final" {
  depends_on = [
    "data.template_file._ulimit",
    "data.template_file._environment_var",
    "data.template_file._port_mappings",
    "data.template_file._mount_points",
    "data.template_file._log_configuration",
  ]

  template = <<JSON
{
  $${val}
}
JSON

  vars {
    val = "${join(",\n    ",
      compact(list(
        "${jsonencode("cpu")}:                ${var.cpu}",
        "${jsonencode("memory")}:             ${var.memory}",
        "${jsonencode("memoryReservation")}:  ${var.memory_reservation}",
        "${jsonencode("entryPoint")}:         ${jsonencode(compact(split(" ", var.entrypoint)))}",
        "${jsonencode("command")}:            ${jsonencode(compact(split(" ", var.command)))}",
        "${jsonencode("links")}:              ${jsonencode(var.links)}",
        "${jsonencode("portMappings")}:      [${data.template_file._port_mappings.rendered}]",
        "${jsonencode("mountPoints")}:       [${join(",\n", data.template_file._mount_points.*.rendered)}]",
        "${jsonencode("ulimits")}:           [${join(",\n", data.template_file._ulimit.*.rendered)}]",
        "${jsonencode("environment")}:       [${join(",\n", data.template_file._environment_var.*.rendered)}]",
        "${jsonencode("logConfiguration")}:   ${data.template_file._log_configuration.rendered}",
        "${jsonencode("name")}:               ${jsonencode(var.name)}",
        "${jsonencode("image")}:              ${jsonencode(var.image)}",
        "${jsonencode("hostname")}:           ${jsonencode(var.hostname)}",
        "${jsonencode("essential")}:          ${var.essential ? true : false }",
        "${jsonencode("volumesFrom")}:       []"
        ))
    )}"
  }
}
