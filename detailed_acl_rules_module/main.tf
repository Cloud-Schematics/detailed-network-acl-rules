##############################################################################
# Create List of Detailed Rules
##############################################################################

locals {

  network_acl_map = {
    for network_acl in var.network_acls :
    (network_acl.shortname) => network_acl
  }

  ##############################################################################
  # detailed rules from variable. separate from json decoded rules to prevent 
  # errors when using ? operator
  ##############################################################################
  detailed_rules_list = var.get_detailed_acl_rules_from_json == true ? [] : flatten([
    for network_acl in var.detailed_acl_rules :
    [
      for rule in network_acl.rules :
      {
        name        = "${network_acl.acl_shortname}-${rule.shortname}"
        network_acl = local.network_acl_map[network_acl.acl_shortname].id
        action      = rule.action
        direction   = rule.direction
        before      = lookup(rule, "add_first", null) == true ? local.network_acl_map[network_acl.acl_shortname].first_rule_id : null
        destination = lookup(rule, "destination", null) == null ? var.network_cidr : rule.destination
        source      = lookup(rule, "source", null) == null ? var.network_cidr : rule.source
        icmp        = lookup(rule, "icmp", null)
        tcp         = lookup(rule, "tcp", null)
        udp         = lookup(rule, "udp", null)
      }
    ]
  ])
  ##############################################################################

  ##############################################################################
  # detailed rules from variable. separate from variable decoded rules to 
  # prevent errors when using ? operator
  ##############################################################################
  detailed_json_rules_list = var.get_detailed_acl_rules_from_json != true ? [] : flatten([
    for network_acl in jsondecode(var.acl_rule_json) :
    [
      for rule in network_acl.rules :
      {
        name        = "${network_acl.acl_shortname}-${rule.shortname}"
        network_acl = local.network_acl_map[network_acl.acl_shortname].id
        action      = rule.action
        direction   = rule.direction
        before      = lookup(rule, "add_first", null) == true ? local.network_acl_map[network_acl.acl_shortname].first_rule_id : null
        destination = lookup(rule, "destination", null) == null ? var.network_cidr : rule.destination
        source      = lookup(rule, "source", null) == null ? var.network_cidr : rule.source
        icmp        = lookup(rule, "icmp", null)
        tcp         = lookup(rule, "tcp", null)
        udp         = lookup(rule, "udp", null)
      }
    ]
  ])
  ##############################################################################
}

##############################################################################

##############################################################################
# Create Rules
##############################################################################

module "dynamic_acl_rules_from_json" {
  source     = "./dynamic_acl_rules"
  rules_list = local.detailed_json_rules_list
}

module "dynamic_acl_rules_from_variable" {
  source     = "./dynamic_acl_rules"
  rules_list = local.detailed_rules_list
}

##############################################################################