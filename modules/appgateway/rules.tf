# resource "azurerm_network_security_group" "AppgwSG_rules" {
#   name                = join("_", [local.common_tags.subscriptionname, local.application.alias, "Appgw-NetworkRules"])
#   resource_group_name = local.network.RG_network
#   location            = local.application.location
# #   security_rule {
# #     name                       = "Allow_GWM"
# #     priority                   = 102
# #     direction                  = "Inbound"
# #     access                     = "Allow"
# #     protocol                   = "Tcp"
# #     source_port_range          = "*"
# #     destination_port_range     = "65200-65535"
# #     source_address_prefix      = "GatewayManager"
# #     destination_address_prefix = "*"
# #   }
#   security_rule {
#     name                       = "Allow_AzureLoadBalancer"
#     priority                   = 110
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "AzureLoadBalancer"
#     destination_port_range     = "Any"
#     source_address_prefix      = "Any"
#     destination_address_prefix = "Any"
#   }
#   security_rule {
#     name                       = "DenyAllInbound_Internet"
#     priority                   = 4096
#     direction                  = "Inbound"
#     access                     = "Deny"
#     protocol                   = "Tcp"
#     source_port_range          = "Any"
#     destination_port_range     = "Any"
#     source_address_prefix      = "Internet"
#     destination_address_prefix = "Any"
#   }
#   security_rule {
#     name                       = "AllowVnetInbound"
#     priority                   = 4092
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "Any"
#     destination_port_range     = "VirtualNetwork"
#     source_address_prefix      = "VirtualNetwork"
#     destination_address_prefix = "Any"
#   }
#   security_rule {
#     name                       = "AllowAzureLoadBalancerInbound"
#     priority                   = 4091
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "Any"
#     destination_port_range     = "Any"
#     source_address_prefix      = "AzureLoadBalancer"
#     destination_address_prefix = "Any"
#   }
#   security_rule {
#     name                       = "DenyAllInbound"
#     priority                   = 105
#     direction                  = "Inbound"
#     access                     = "Deny"
#     protocol                   = "Tcp"
#     source_port_range          = "Any"
#     destination_port_range     = "Any"
#     source_address_prefix      = "Any"
#     destination_address_prefix = "Any"
#   }
#   security_rule {
#     name                       = "AllowVnetOutbound"
#     priority                   = 4090
#     direction                  = "Outbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "Any"
#     destination_port_range     = "Any"
#     source_address_prefix      = "VirtualNetwork"
#     destination_address_prefix = "Any"
#   }
#   security_rule {
#     name                       = "AllowInternetOutbound"
#     priority                   = 4094
#     direction                  = "Outbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "Any"
#     destination_port_range     = "Any"
#     source_address_prefix      = "Internet"
#     destination_address_prefix = "Any"
#   }
#   security_rule {
#     name                       = "DenyAllOutbound"
#     priority                   = 4093
#     direction                  = "Outbound"
#     access                     = "Deny"
#     protocol                   = "Tcp"
#     source_port_range          = "Any"
#     destination_port_range     = "Any"
#     source_address_prefix      = "Any"
#     destination_address_prefix = "Any"
#   }
#   tags = merge(local.application,
#   { Application = "Appgw Nsg's", name = "jenkins_appgw" })
# }