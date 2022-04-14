terraform {
  required_version = "~> 1.0"
  experiments      = [module_variable_optional_attrs]
}

resource "azurerm_virtual_network" "main" {
  name                    = var.vnet.name
  location                = var.vnet.location
  resource_group_name     = var.vnet.resource_group_name
  address_space           = var.vnet.address_space
  dns_servers             = var.vnet.dns_servers != null ? var.vnet.dns_servers : []
  bgp_community           = var.vnet.bgp_community != null ? var.vnet.bgp_community : null
  edge_zone               = var.vnet.edge_zone != null ? var.vnet.edge_zone : null
  flow_timeout_in_minutes = var.vnet.flow_timeout_in_minutes != null ? var.vnet.flow_timeout_in_minutes : null
  tags                    = var.vnet.tags
  dynamic "ddos_protection_plan" {
    iterator = self
    for_each = var.vnet.ddos_protection_plan != null ? { default = "default" } : {}
    content {
      id     = var.vnet.ddos_protection_plan.id
      enable = var.vnet.ddos_protection_plan.enable
    }
  }
}

resource "azurerm_subnet" "default" {
  for_each                                       = var.subnet
  name                                           = each.value.name
  resource_group_name                            = azurerm_virtual_network.main.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.main.name
  address_prefixes                               = each.value.address_prefixes
  enforce_private_link_endpoint_network_policies = lookup(each.value, "enforce_private_link_endpoint_network_policies", false)
  enforce_private_link_service_network_policies  = lookup(each.value, "enforce_private_link_service_network_policies", false)
  service_endpoints                              = lookup(each.value, "service_endpoints", [])
  service_endpoint_policy_ids                    = lookup(each.value, "service_endpoint_policy_ids", [])
  dynamic "delegation" {
    iterator = self
    for_each = each.value.delegation != null ? { default = "default" } : {}
    content {
      name = each.value.delegation.name
      service_delegation {
        name    = each.value.delegation.name
        actions = each.value.delegation.actions
      }
    }
  }
}

resource "azurerm_network_security_group" "default" {
  for_each            = { for k, v in var.subnet : k => v if v.nsg != null }
  name                = each.value.nsg.name
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_virtual_network.main.resource_group_name
  dynamic "security_rule" {
    for_each = each.value.nsg.security_rule
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      description                  = security_rule.value.description
      direction                    = security_rule.value.direction
      source_address_prefix        = security_rule.value.source_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes
      destination_port_range       = security_rule.value.destination_port_range
      destination_port_ranges      = security_rule.value.destination_port_ranges
      source_port_range            = security_rule.value.source_port_range
      source_port_ranges           = security_rule.value.source_port_ranges
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "default" {
  for_each                  = { for k, v in var.subnet : k => v if v.nsg != null }
  subnet_id                 = azurerm_subnet.default[each.key].id
  network_security_group_id = azurerm_network_security_group.default[each.key].id
}