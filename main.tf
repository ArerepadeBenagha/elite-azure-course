resource "azurerm_resource_group" "farenow" {
  name     = "farenow-travel"
  location = var.location
}

############## VM & Network ###############
resource "azurerm_windows_virtual_machine" "example" {
  name                             = "${var.alias}-vm"
  resource_group_name              = azurerm_resource_group.farenow.name
  location                         = var.location
  size                             = "Standard_F2"
  admin_username                   = "adminuser"
  admin_password                   = "P@$$w0rd1234!"
  # delete_os_disk_on_termination    = true
  # delete_data_disks_on_termination = true
  network_interface_ids = [
    azurerm_network_interface.dev-interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "dev"
  }
}

###########################

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

    security_rule {
    name                       = "rdp"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = var.rdp
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

########## -----------------------------#
module "azure-bastion" {
  source                              = "./modules/azure-network/"
  resource_group_name                 = "farenow-travel"
  virtual_network_name                = "dev"
  azure_bastion_service_name          = "mybastion-service"
  azure_bastion_subnet_address_prefix = ["10.0.0.0/24"]
}