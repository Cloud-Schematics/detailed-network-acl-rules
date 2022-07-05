##############################################################################
# Fail if acl shortname for rule not found in var.network_acls
##############################################################################

locals {
  CONFIGURATION_FAILURE_unfound_acl_shortname_in_variable = regex("true",
    var.get_detailed_acl_rules_from_json == true
    ? true
    : length([
      for network_acl in var.detailed_acl_rules.*.acl_shortname :
      false if !contains(var.network_acls.*.shortname, network_acl)
    ]) == 0
  )

  CONFIGURATION_FAILURE_unfound_acl_shortname_in_json = regex("true",
    var.get_detailed_acl_rules_from_json != true
    ? true
    : length([
      for network_acl in local.acl_json.*.acl_shortname :
      false if !contains(var.network_acls.*.shortname, network_acl)
    ]) == 0
  )
}

##############################################################################