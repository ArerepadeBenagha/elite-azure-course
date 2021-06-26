
resource "azurerm_virtual_network" "farenow" {
  name                = var.alias
  location            = var.location
  resource_group_name = azurerm_resource_group.farenow.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet-1" {
  name                 = var.alias
  resource_group_name  = azurerm_resource_group.farenow.name
  virtual_network_name = azurerm_virtual_network.farenow.name
  address_prefixes       = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "allow-ssh" {
  name                = var.alias
  location            = var.location
  resource_group_name = azurerm_resource_group.farenow.name

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }

  tags = {
    environment = "dev-securitygroup"
  }
}

resource "azurerm_public_ip" "dev-public-ip" {
  name                = var.alias
  resource_group_name = azurerm_resource_group.farenow.name
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev-ip"
  }
}

resource "azurerm_network_interface" "dev-interface" {
  name                = var.alias
  location            = var.location
  resource_group_name = azurerm_resource_group.farenow.name

  ip_configuration {
    name                          = var.alias
    subnet_id                     = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev-public-ip.id
  }
}

# ################

# data "azurerm_resource_group" "rg" {
#   name = var.resource_group_name
# }

# data "azurerm_virtual_network" "vnet" {
#   name                = var.virtual_network_name
#   resource_group_name = data.azurerm_resource_group.rg.name
# }

# resource "azurerm_subnet" "abs_snet" {
#   count                = var.azure_bastion_subnet_address_prefix != null ? 1 : 0
#   name                 = "azure-bastion"
#   resource_group_name  = data.azurerm_resource_group.rg.name
#   virtual_network_name = data.azurerm_virtual_network.vnet.name
#   address_prefixes     = var.azure_bastion_subnet_address_prefix
#     delegation {
#     name = "delegation"

#     service_delegation {
#       name    = "Microsoft.ContainerInstance/containerGroups"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
#     }
#   }
# }
# #############
# variable "resource_group_name" {
#   description = "A container that holds related resources for an Azure solution"
#   default     = "farenow-travel"
# }

# variable "virtual_network_name" {
#   description = "The name of the virtual network"
#   default     = "dev"
# }

# variable "azure_bastion_subnet_address_prefix" {
#   description = "The address prefix to use for the Azure Bastion subnet"
#   default     = ["10.0.1.0/24"]
# }
