////////////// data Lookup ////////
data "azurerm_subnet" "subnet" {
  name                 = "public-sb"
  virtual_network_name = local.network.vnet_name
  resource_group_name  = local.network.RG_network
}