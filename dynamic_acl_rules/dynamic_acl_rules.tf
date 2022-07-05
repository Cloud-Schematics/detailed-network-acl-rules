##############################################################################
# Rules List
##############################################################################

variable "rules_list" {
  description = "List of network ACL rules to create"
  type = list(
    object({
      name        = string
      network_acl = string
      before      = optional(string)
      source      = string
      destination = string
      action      = string
      direction   = string
      tcp = optional(
        object({
          port_max        = optional(number)
          port_min        = optional(number)
          source_port_max = optional(number)
          source_port_min = optional(number)
        })
      )
      udp = optional(
        object({
          port_max        = optional(number)
          port_min        = optional(number)
          source_port_max = optional(number)
          source_port_min = optional(number)
        })
      )
      icmp = optional(
        object({
          type = optional(number)
          code = optional(number)
        })
      )
    })
  )
}

##############################################################################

##############################################################################
# List To Map
##############################################################################

module "deny_rule_map" {
  source = "../list_to_map"
  list   = var.rules_list
}

##############################################################################

##############################################################################
# Create Rules
##############################################################################

resource "ibm_is_network_acl_rule" "dynamic_deny_rules" {
  for_each    = module.deny_rule_map.value
  network_acl = each.value.network_acl
  name        = each.value.name
  before      = each.value.before
  action      = each.value.action
  direction   = each.value.direction
  destination = each.value.destination
  source      = each.value.source

  dynamic "icmp" {
    for_each = (
      # Only allow creation of icmp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      each.value.icmp == null
      ? []
      : length([
        for value in ["type", "code"] :
        true if lookup(each.value["icmp"], value, null) == null
      ]) == 2
      ? [] # if all values null empty array
      : [each.value]
    )

    content {
      type = lookup(each.value.icmp, "type", null)
      code = lookup(each.value.icmp, "code", null)
    }
  }

  dynamic "tcp" {
    for_each = (
      # Only allow creation of tcp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      # the default behavior will be to set `null` `port_min` and `source_port_min`
      # values to 1 if null and `port_max` and `source_port_max` to 65535 if null
      each.value.tcp == null
      ? []
      : length([
        for value in ["port_min", "port_max", "source_port_min", "source_port_max"] :
        true if lookup(each.value["tcp"], value, null) == null
      ]) == 4 # will be 4 if all null
      ? []
      : [each.value]
    )

    content {
      port_min        = lookup(each.value.tcp, "port_min", null)
      port_max        = lookup(each.value.tcp, "port_max", null)
      source_port_min = lookup(each.value.tcp, "source_port_min", null)
      source_port_max = lookup(each.value.tcp, "source_port_max", null)
    }
  }

  dynamic "udp" {
    for_each = (
      # Only allow creation of udp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      # the default behavior will be to set `null` `port_min` and `source_port_min`
      # values to 1 if null and `port_max` and `source_port_max` to 65535 if null
      each.value.udp == null
      ? []
      : length([
        for value in ["port_min", "port_max", "source_port_min", "source_port_max"] :
        true if lookup(each.value["udp"], value, null) == null
      ]) == 4 # will be 4 if all null
      ? []
      : [each.value]
    )

    content {
      port_min        = lookup(each.value.udp, "port_min", null)
      port_max        = lookup(each.value.udp, "port_max", null)
      source_port_min = lookup(each.value.udp, "source_port_min", null)
      source_port_max = lookup(each.value.udp, "source_port_max", null)
    }
  }
}

##############################################################################