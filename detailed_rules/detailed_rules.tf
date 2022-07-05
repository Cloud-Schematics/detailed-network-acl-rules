##############################################################################
# Variables
##############################################################################

variable "rule_list" {
  description = "List of rules"
  type = list(
    object({
      acl_shortname = string
      rules = list(
        object({
          shortname   = string
          action      = string
          direction   = string
          add_first   = optional(bool)
          destination = optional(string)
          source      = optional(string)
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
    })
  )
}

variable "acl_data" {
  description = "Reference to acl data"
}

variable "first_rules" {
  description = "Reference to first rules local"
}

variable "network_cidr" {
  description = "CIDR block to use as the source for global outbound rules and destination for global inbound rules."
  type        = string
  default     = "10.0.0.0/8"
}

##############################################################################

##############################################################################
# Output List
##############################################################################

output "value" {
  description = "Composed list of rules"
  value = flatten([
    for network_acl in var.rule_list :
    [
      for rule in network_acl.rules :
      {
        name        = "${network_acl.acl_shortname}-${rule.shortname}"
        network_acl = var.acl_data[network_acl.acl_shortname].id
        action      = rule.action
        direction   = rule.direction
        before      = lookup(rule, "add_first", null) == true ? var.first_rules[network_acl.acl_shortname] : null
        destination = lookup(rule, "destination", null) == null ? var.network_cidr : rule.destination
        source      = lookup(rule, "source", null) == null ? var.network_cidr : rule.source
        icmp        = lookup(rule, "icmp", null)
        tcp         = lookup(rule, "tcp", null)
        udp         = lookup(rule, "udp", null)
      }
    ]
  ])
}

##############################################################################