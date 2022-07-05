##############################################################################
# IBM Cloud Provider
##############################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = 60
}

##############################################################################

##############################################################################
# Get Network ACLs From Data
##############################################################################

locals {
  acl_map = {
    for network_acl in var.network_acls :
    (network_acl.shortname) => network_acl.id
  }
}

data "ibm_is_network_acl" "network_acl" {
  for_each    = local.acl_map
  network_acl = each.value
}

locals {
  # Get the first rule of each ACL
  first_rules = {
    # For each acl in list map the shortname to the rule at rules[0].
    for network_acl in var.network_acls :
    (network_acl.shortname) => data.ibm_is_network_acl.network_acl[network_acl.shortname].rules[0].id
  }
}

##############################################################################

##############################################################################
# Create List of Detailed Rules
##############################################################################

locals {
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
        network_acl = data.ibm_is_network_acl.network_acl[network_acl.acl_shortname].id
        action      = rule.action
        direction   = rule.direction
        before      = lookup(rule, "add_first", null) == true ? local.first_rules[network_acl.acl_shortname] : null
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
  acl_json = jsondecode(file("./acl_rules.json"))
  detailed_json_rules_list = var.get_detailed_acl_rules_from_json != true ? [] : flatten([
    for network_acl in jsondecode(file("./acl_rules.json")) :
    [
      for rule in network_acl.rules :
      {
        name        = "${network_acl.acl_shortname}-${rule.shortname}"
        network_acl = data.ibm_is_network_acl.network_acl[network_acl.acl_shortname].id
        action      = rule.action
        direction   = rule.direction
        before      = lookup(rule, "add_first", null) == true ? local.first_rules[network_acl.acl_shortname] : null
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

module "dynamic_acl_rules_list_from_variable" {
  source       = "./detailed_rules"
  rule_list    = var.get_detailed_acl_rules_from_json == true ? [] : var.detailed_acl_rules
  acl_data     = data.ibm_is_network_acl.network_acl
  first_rules  = local.first_rules
  network_cidr = var.network_cidr
}

module "dynamic_acl_rules_from_variable" {
  source     = "./dynamic_acl_rules"
  rules_list = module.dynamic_acl_rules_list_from_variable.value
}

##############################################################################