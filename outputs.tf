output "properties" {
  value = azurerm_virtual_network.main
}

# Subnet output example
# output "subnet" {
#   value = module.virtual_network.properties["main"].subnet.*[0].id
# }