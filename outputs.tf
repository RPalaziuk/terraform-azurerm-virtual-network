output "properties" {
  value = {
    vnet   = azurerm_virtual_network.main
    subnet = azurerm_subnet.default
    nsg    = azurerm_network_security_group.default
  }
}