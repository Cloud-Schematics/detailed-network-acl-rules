##############################################################################
# ACL Data Variables
##############################################################################

variable "network_acls" {
  description = "Network ACLs to retrieve from data. This data is intended to be retrieved from the `vpc_network_acls` output from the ICSE Flexible VPC Network template (https://github.com/Cloud-Schematics/easy-flexible-vpc-network)."
  type = list(
    object({
      id            = string
      name          = string
      shortname     = string
      first_rule_id = optional(string)
    })
  )
  default = []
}

variable "network_cidr" {
  description = "CIDR block to use as the source for global outbound rules and destination for global inbound rules."
  type        = string
  default     = "10.0.0.0/8"
}


##############################################################################

##############################################################################
# Global Rules to Add
##############################################################################

variable "apply_new_rules_before_old_rules" {
  description = "When set to `true`, any new rules to be applied to existing Network ACLs will be added **before** existing rules and after any detailed rules that will be added. Otherwise, rules will be added after."
  type        = bool
  default     = true
}

variable "deny_all_tcp_ports" {
  description = "Deny all inbound and outbound TCP traffic on each port in this list."
  type        = list(number)
  default     = [22, 80]
}

variable "deny_all_udp_ports" {
  description = "Deny all inbound and outbound UDP traffic on each port in this list."
  type        = list(number)
  default     = [22, 80]
}

##############################################################################

##############################################################################
# Detailed ACL Rules Variables
##############################################################################

variable "get_detailed_acl_rules_from_json" {
  description = "Decode local file `acl_rules.json` for the automated creation of Network ACL rules."
  type        = bool
  default     = true
}

variable "acl_rule_json" {
  description = "Decoded filedata for ACL rules"
  type        = string
  default     = null
}

variable "detailed_acl_rules" {
  description = "List describing network ACLs and rules to add."
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

##############################################################################