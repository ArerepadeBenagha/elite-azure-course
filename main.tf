resource "azurerm_resource_group" "eliteInfra" {
  name     = local.network.resource_group_name
  location = local.application.location
  tags     = local.common_tags
}
resource "azurerm_resource_group" "RG_net" {
  name     = local.network.RG_network
  location = local.application.location
  tags     = local.common_tags
}
resource "azurerm_public_ip" "public-pip" {
  name                = local.application.alias
  resource_group_name = local.network.RG_network
  location            = local.application.location
  allocation_method   = "Dynamic"

  tags = merge(local.application,
  { Application = "jenkins pip", region = local.application.location })
}
resource "azurerm_network_interface" "interface" {
  name                = local.application.alias
  location            = local.application.location
  resource_group_name = local.network.RG_network
  ip_configuration {
    name                          = local.application.alias
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-pip.id
  }
  tags = merge(local.application,
  { Application = "Nic", region = local.application.location })
}

# ##--------------------------------------#
# //         Bastion Module              
# ##--------------------------------------#
# module "azure-bastion" {
#   source                              = "./modules/azure-network/"
#   RG_network                          = local.network.RG_network
#   vnet_name                           = local.network.vnet_name
#   azure_bastion_service_name          = "mybastion-service"
#   azure_bastion_subnet_address_prefix = ["10.0.2.0/24"]

#   tags = merge(local.application,
#   { Application = "jenkins bastion", region = local.application.location })
# }

##--------------------------------------#
//          Vnet Module             
##--------------------------------------#
# module "vnet" {
#   source              = "./modules/vnet/"
#   resource_group_name = local.network.RG_network
#   address_space       = ["10.0.0.0/16"]
#   subnet_prefixes     = ["10.0.1.0/24"]
#   subnet_names        = ["public-sb"]
#   vnet_name           = local.network.vnet_name
#   RG_network          = local.network.RG_network
#   vnet_location       = local.application.location

#   nsg_ids = {
#     public-sb = azurerm_network_security_group.SG_rules.id
#   }
#   tags = merge(local.application,
#   { Application = "jenkins vnet", name = local.application.alias })
# }

# # ############# VM & Network ###############
# resource "azurerm_linux_virtual_machine" "jenkins-vm" {
#   name                  = local.application.vm_name
#   resource_group_name   = azurerm_resource_group.eliteInfra.name
#   location              = local.application.location
#   size                  = "Standard_F2"
#   admin_username        = "adminuser"
#   network_interface_ids = [azurerm_network_interface.interface.id]
#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file(var.path_to_public_key)
#   }
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }
#   # extension {
#   #   name                 = "InstallCustomScript"
#   #   publisher            = "Microsoft.Azure.Extensions"
#   #   type                 = "CustomScript"
#   #   type_handler_version = "2.0"
#   #   settings             = <<SETTINGS
#   #       {
#   #         "fileUris": ["https://raw.githubusercontent.com/ArerepadeBenagha/elite-azure-course/blob/master/scripts.sh"], 
#   #         "commandToExecute": "./scripts.sh"
#   #       }
#   #     SETTINGS
#   # }
#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

#   tags = merge(local.application,
#   { Application = "jenkins vm", name = local.application.app_name })
# }

# ##--------------------------------------#
# //         Appgw Module              
# ##--------------------------------------#

# locals {
#   ui-beap       = join("-", [local.application.alias, "ui-beap"])
#   api-beap      = join("-", [local.application.alias, "api-beap"])
#   ui-htst       = join("-", [local.application.alias, "ui-htst"])
#   api-htst      = join("-", [local.application.alias, "api-htst"])
#   http-listener = join("-", [local.application.alias, "http-listener"])
#   http-url-path = join("-", [local.application.alias, "http-url-path"])
#   appgw-probe   = join("-", [local.application.alias, "appgw-probe"])
#   http-rqrt     = join("-", [local.application.alias, "http-rqrt"])
# }
# module "app-gateway" {
#   source      = "./modules/appgateway"
#   name        = join("-", [local.application.alias, "appgw", ])
#   rg_location = local.application.location
#   rg_name     = local.network.RG_network
#   backend_address_pools = [{
#       name         = local.ui-beap
#       ip_addresses = null
#       fqdns        = null
#     }]
#   backend_http_settings = [{
#       name                                      = local.ui-htst
#       path                                      = "/"
#       is_https                                  = false
#       request_timeout                           = 30
#       probe_name                                = local.appgw-probe
#       pick_host_name_from_backend_http_settings = false
#   }]
#   http_listeners = [{
#       name                 = local.http-listener
#       ssl_certificate_name = null
#       host_name            = null
#       require_sni          = null
#     }]
#   probes = [{
#     name                                      = local.appgw-probe
#     path                                      = "/"
#     is_https                                  = false
#     pick_host_name_from_backend_http_settings = false
#   }]
#   basic_request_routing_rules = [{
#     name                       = local.http-rqrt
#     http_listener_name         = local.http-listener
#     backend_address_pool_name  = local.ui-beap
#     backend_http_settings_name = local.ui-htst
#   }]
# }