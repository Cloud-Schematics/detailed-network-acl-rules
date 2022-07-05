# Detailed Network ACL Rules

Manage VPC Network Access Control List rules with HCL Variables or JSON data.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Dynamic Deny All Rules](#dynamic-deny-all-rules)
3. [Defining ACL Rules With HCL](#defining-acl-rules-with-hcl)
4. [Defining ACL Rules With JSON](#defining-acl-rules-with-json)

---

## Prerequisites

- Already created VPC Network with ACLs
- Initialize the [detailed_acl_rules_module](./detailed_acl_rules_module/) in a VPC network template.

---

## Dynamic Deny All Rules

This module uses the [deny_all_tcp_ports variable](./variables.tf#L54) and the [deny_all_udp_ports variable](./variables.tf#L60) to create rules to deny traffic. For each port, a rule is created in each network ACL to deny both inbound and outbound traffic on that port from any source to the [network CIDR](./variables.tf#L35). 

Network ACLs have a limit of [100 Rules per ACL](https://cloud.ibm.com/docs/vpc?topic=vpc-quotas#acl-quotas).

---

## Defining ACL Rules With HCL

Using the [detailed_acl_rules variable](./variables.tf#L78) any number of rules for any number of Network ACLs can be configured.

```terraform
  list(
    object({
      acl_shortname = string               # Reference Name of ACL
      rules = list(
        object({
          shortname   = string             # Reference name for rule, will be added to `acl_shortname`
          action      = string             # Can be allow or deny
          direction   = string             # Can be inbound or outbound
          add_first   = optional(bool)     # Add rule before existing rules if `true`, otherwise will be added to the end
          destination = optional(string)   # Destination CIDR, defaults to network CIDR
          source      = optional(string)   # Source CIDR, defaults to network CIDR
          ##############################################################################
          # One of the following blocks can be added to each rule
          ##############################################################################
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
```

---

## Defining ACL Rules With JSON

To allow for easier and faster writing of complex data, the file [acl-rules.json](./acl-rules.json). To use the JSON file to create network ACL rules, set the [get_detailed_acl_rules_from_json variable](./variables.tf#L72) to `true`. The JSON Schema for ACL rules is identical to the HCL rules variable.

---

## Module Variables

Name                             | Description                                                                                                                                                                                                               | Default
-------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------
network_acls                     | Network ACLs to retrieve from data. This data is intended to be retrieved from the `vpc_network_acls` output from the ICSE Flexible VPC Network template (https://github.com/Cloud-Schematics/easy-flexible-vpc-network). | []
network_cidr                     | CIDR block to use as the source for global outbound rules and destination for global inbound rules.                                                                                                                       | 10.0.0.0/8
apply_new_rules_before_old_rules | When set to `true`, any new rules to be applied to existing Network ACLs will be added **before** existing rules and after any detailed rules that will be added. Otherwise, rules will be added after.                   | true
deny_all_tcp_ports               | Deny all inbound and outbound TCP traffic on each port in this list.                                                                                                                                                      | [22, 80]
deny_all_udp_ports               | Deny all inbound and outbound UDP traffic on each port in this list.                                                                                                                                                      | [22, 80]
get_detailed_acl_rules_from_json | Decode local file `acl_rules.json` for the automated creation of Network ACL rules.                                                                                                                                       | true
acl_rule_json                    | Decoded filedata for ACL rules                                                                                                                                                                                            | null
detailed_acl_rules               | List describing network ACLs and rules to add.                                                                                                                                                                            |