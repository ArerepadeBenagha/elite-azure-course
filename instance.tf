# resource "azurerm_virtual_machine" "main" {
#   name                  = "${var.alias}-vm"
#   location              = var.location
#   resource_group_name   = azurerm_resource_group.farenow.name
#   network_interface_ids = [azurerm_network_interface.dev-interface.id]
#   vm_size               = "Standard_DS1_v2"

#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }
#   storage_os_disk {
#     name              = "myosdisk1"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "farenow-dev-VM"
#     admin_username = "azureuser"
#     #    admin_password = "Password1234!"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = true
#     ssh_keys {
#       key_data = file("mykey.pub")
#       path     = "/home/azureuser/.ssh/authorized_keys"
#     }
#   }

#   tags = {
#     environment = "dev"
#   }
# }
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
