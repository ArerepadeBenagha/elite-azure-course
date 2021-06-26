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
