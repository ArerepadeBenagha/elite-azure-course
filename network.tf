
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
  address_prefix       = "10.0.1.0/24"
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
