resource "azurerm_network_interface" "terraform-netint" {
  name                      = "terraform-netint"
  location                  = "${azurerm_resource_group.terraform-rg.location}"
  resource_group_name       = "${azurerm_resource_group.terraform-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.terraform-sg.id}"

  ip_configuration {
    name                          = "testconf"
    subnet_id                     = "${azurerm_subnet.terraform-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.terraform-publicip.id}"
  }
}
