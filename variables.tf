variable "vnet" {
  type = object({
    name                    = string
    resource_group_name     = string
    location                = string
    address_space           = list(string)
    dns_servers             = optional(list(string))
    bgp_community           = optional(string)
    edge_zone               = optional(string)
    flow_timeout_in_minutes = optional(number)
    ddos_protection_plan = optional(object({
      id     = optional(string)
      enable = optional(bool)
    }))
    tags = map(string)
  })
}

variable "subnet" {
  type = map(object({
    name                                           = string
    address_prefixes                               = list(string)
    enforce_private_link_endpoint_network_policies = optional(bool)
    enforce_private_link_service_network_policies  = optional(bool)
    service_endpoints                              = optional(list(string))
    service_endpoint_policy_ids                    = optional(list(string))
    delegation = optional(object({
      name    = optional(string)
      actions = optional(list(string))
    }))
    nsg = optional(object({
      name = string
      security_rule = list(object({
        description                  = optional(string)
        direction                    = optional(string)
        name                         = optional(string)
        access                       = optional(string)
        priority                     = optional(number)
        source_address_prefix        = optional(string)
        source_address_prefixes      = optional(list(string))
        destination_address_prefix   = optional(string)
        destination_address_prefixes = optional(list(string))
        destination_port_range       = optional(string)
        destination_port_ranges      = optional(list(string))
        protocol                     = optional(string)
        source_port_range            = optional(string)
        source_port_ranges           = optional(list(string))
      }))
    }))
  }))
}