resource "azurerm_virtual_machine" "terraform-vm" {
  name                  = "terraform-vm"
  location              = "${azurerm_resource_group.terraform-rg.location}"
  resource_group_name   = "${azurerm_resource_group.terraform-rg.name}"
  vm_size               = "Standard_B1ls"
  network_interface_ids = ["${azurerm_network_interface.terraform-netint.id}"]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "terraform_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "terraform"
    admin_username = "Damocles"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/Damocles/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }
}
