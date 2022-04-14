# terraform-azurerm-virtual-network
Terraform module for Azure virtual network and related resources.

## Usage

### Example useage

`Create Virtual Network only`

```hcl
module "virtual_network" {
  source    = source = ""git@github.com:RPalaziuk/terraform-azurerm-virtual-network.git?ref=main""
  providers = { azurerm = azurerm }
  vnet = {
    name                = "virtual-network"
    location            = azurerm_resource_group.default.location
    resource_group_name = azurerm_resource_group.default.name
    address_space       = ["10.0.0.0/16"]
    tags                = azurerm_resource_group.default.tags
  }
  subnet = {}
}
```

`Create Virtual Network + Subnet`

```hcl
module "virtual_network_and_subnet" {
  source    = source = ""git@github.com:RPalaziuk/terraform-azurerm-virtual-network.git?ref=main""
  providers = { azurerm = azurerm }
  vnet = {
    name                = "virtual-network"
    location            = azurerm_resource_group.default.location
    resource_group_name = azurerm_resource_group.default.name
    address_space       = ["10.0.0.0/16"]
    tags                = azurerm_resource_group.default.tags
  }
  subnet = {
    first = {
      name             = "subnet-1"
      address_prefixes = ["10.0.0.0/24"]
    }
  }
}
```

`Create Virtual Network + Subnet + Network Security Group`

```hcl
module "virtual_network_and_subnet_with_nsg" {
  source    = source = ""git@github.com:RPalaziuk/terraform-azurerm-virtual-network.git?ref=main""
  providers = { azurerm = azurerm }
  vnet = {
    name                = "virtual-network"
    location            = azurerm_resource_group.default.location
    resource_group_name = azurerm_resource_group.default.name
    address_space       = ["10.0.0.0/16"]
    tags                = azurerm_resource_group.default.tags
  }
  subnet = {
    first = {
      name             = "subnet-1"
      address_prefixes = ["10.0.0.0/24"]
      nsg = {
        name = "security-group"
        security_rule = [
          {
            name                       = "allow-ssh"
            description                = "open ssh port"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "22"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
          },
        ]
      }
    }
  }
}
```

## Inputs

### Variable - `vnet`

| Name | Description | Options | Type | Default | Required |
|------|-------------|:----:|:----:|:-----:|:-----:|
| `name` | The name of virtual network. | | string | `none` | yes |
| `location` | Resource location |  | string | `none` | yes |
| `resource_group_name` | Resource group name |  | string | `none` | yes |
| `address_space` | The address space that is used the virtual network. You can supply more than one address space |  | list | `none` | yes |

### Variable - `subnet`

| Name | Description | Options | Type | Default | Required |
|------|-------------|:----:|:----:|:-----:|:-----:|
| `name` | The name of subnet |  | string | `none` | yes |
| `address_prefixes` | The address prefixes to use for the subnet. |  | list | `none` | yes |
| `nsg` | Configuration of Network Security Group associated with subnet |  | object | `none` | no |

___

## Outputs - `properties`

| Name | Description |
|------|-------------|
| vnet | virtual network details |
| subnet | subnet details |
| nsg | network security group details |

### Example

```
output "vnet-details" {
  value = module.virtual_network.properties.vnet.id
}

output "subnet-details" {
  value = module.virtual_network.properties.subnet["first"].id
}

output "nsg-details" {
  value = module.virtual_network.properties.nsg["first"].id
}
```