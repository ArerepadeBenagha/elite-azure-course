resource "azurerm_resource_group" "eliteInfra" {
  name     = "eliteInfra"
  location = var.location
}
data "azurerm_subnet" "subnet" {
  name                 = "public-sb"
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}
resource "azurerm_public_ip" "dev-public-ip" {
  name                = var.alias
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev-ip"
  }
}

resource "azurerm_network_interface" "dev-interface" {
  name                = var.alias
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.alias
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev-public-ip.id
  }
}

##--------------------------------------#
##         Bastion Module              ##
##--------------------------------------#
module "azure-bastion" {
  source                              = "./modules/azure-network/"
  resource_group_name                 = var.resource_group_name
  virtual_network_name                = var.vnet_name
  azure_bastion_service_name          = "mybastion-service"
  azure_bastion_subnet_address_prefix = ["10.0.0.0/24"]
}

##--------------------------------------#
##            Vnet Module              ##
##--------------------------------------#
module "vnet" {
  source              = "./modules/vnet/"
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["public-sb"]

  nsg_ids = {
    public-sb = azurerm_network_security_group.ssh.id
  }
  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}
resource "azurerm_network_security_group" "ssh" {
  name                = "ssh"
  resource_group_name = var.resource_group_name
  location            = var.location
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

  security_rule {
    name                       = "jenkins-port"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = var.ssh-source-address
  }

  tags = {
    environment = "dev-securitygroup"
  }
}

# ############# VM & Network ###############
resource "azurerm_linux_virtual_machine" "jenkins-vm" {
  name                = "${var.alias}-jenkinsvm"
  resource_group_name = azurerm_resource_group.eliteInfra.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  # delete_os_disk_on_termination    = true
  # delete_data_disks_on_termination = true
  network_interface_ids = [
    azurerm_network_interface.dev-interface.id,
  ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  tags = {
    environment = "dev"
  }
}
