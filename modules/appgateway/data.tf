data "azurerm_virtual_network" "vnet" {
  name                = local.network.vnet_name
  resource_group_name = local.network.RG_network
}

data "azurerm_resource_group" "rg" {
  name = local.network.RG_network
}
data "azurerm_network_interface" "dev_nic" {
  name                = "Dev"
  resource_group_name = local.network.RG_network
}
