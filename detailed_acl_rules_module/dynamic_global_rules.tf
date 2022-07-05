##############################################################################
# Create inbound and outbound rules for each port in deny lists for TCP + UDP
##############################################################################
locals {
  global_port_deny_rules = flatten([
    # For each network ACL
    for network_acl in var.network_acls :
    [
      [
        # For each port in deny all tcp ports create inbound and outbound rules
        for port in var.deny_all_tcp_ports :
        [
          {
            name        = "${network_acl.shortname}-deny-inbound-tcp-${port}"
            network_acl = local.network_acl_map[network_acl.shortname].id
            before      = var.apply_new_rules_before_old_rules == true ? local.network_acl_map[network_acl.shortname].first_rule_id : null
            source      = "0.0.0.0/0"
            destination = var.network_cidr
            action      = "deny"
            direction   = "inbound"
            tcp = {
              port_min = port
              port_max = port
            }
          },
          {
            name        = "${network_acl.shortname}-deny-outbound-tcp-${port}"
            network_acl = local.network_acl_map[network_acl.shortname].id
            before      = var.apply_new_rules_before_old_rules == true ? local.network_acl_map[network_acl.shortname].first_rule_id : null
            destination = "0.0.0.0/0"
            source      = var.network_cidr
            direction   = "outbound"
            action      = "deny"
            tcp = {
              source_port_min = port
              source_port_max = port
            }
          }
        ]
      ],
      [
        # For each UDP port create inbound and outbound rules
        for port in var.deny_all_udp_ports :
        [
          {
            name        = "${network_acl.shortname}-deny-inbound-udp-${port}"
            network_acl = local.network_acl_map[network_acl.shortname].id
            before      = var.apply_new_rules_before_old_rules == true ? local.network_acl_map[network_acl.shortname].first_rule_id : null
            source      = "0.0.0.0/0"
            destination = var.network_cidr
            direction   = "inbound"
            action      = "deny"
            udp = {
              port_min = port
              port_max = port
            }
          },
          {
            name        = "${network_acl.shortname}-deny-outbound-udp-${port}"
            network_acl = local.network_acl_map[network_acl.shortname].id
            before      = var.apply_new_rules_before_old_rules == true ? local.network_acl_map[network_acl.shortname].first_rule_id : null
            destination = "0.0.0.0/0"
            source      = var.network_cidr
            direction   = "outbound"
            action      = "deny"
            udp = {
              source_port_min = port
              source_port_max = port
            }
          }
        ]
      ]
    ]
  ])
}
##############################################################################

##############################################################################
# Dynamic Deny Rules
##############################################################################

module "dynamic_deny_rules" {
  source     = "./dynamic_acl_rules"
  rules_list = local.global_port_deny_rules
  # Await addition of other rules
  depends_on = [module.dynamic_acl_rules_from_json, module.dynamic_acl_rules_from_json]
}

##############################################################################