resource "azurerm_network_security_group" "SG_rules" {
  name                = join("_", [local.common_tags.subscriptionname, local.application.alias, "NetworkRules"])
  resource_group_name = local.network.RG_network
  location            = local.application.location
  security_rule {
    name                       = "rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = var.rdp
  }
  security_rule {
    name                       = "jenkins-port"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }
  security_rule {
    name                       = "ssh"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }
  security_rule {
    name                       = "deployment-app"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8180"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }
  security_rule {
    name                       = "deployment-app0"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8280"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }
  security_rule {
    name                       = "deployment-jen"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9990"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }
  security_rule {
    name                       = "deployment-jen0"
    priority                   = 106
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }
  security_rule {
    name                       = "deployment-jen1"
    priority                   = 107
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }

  tags = merge(local.application,
  { Application = "jenkins security rules", name = "jenkins_app" })
}
