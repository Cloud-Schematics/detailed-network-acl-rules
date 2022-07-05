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