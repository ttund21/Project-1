resource "azurerm_subnet" "terraform-subnet" {
  name                 = "terraform-subnet"
  virtual_network_name = "${azurerm_virtual_network.terraform-vnet.name}"
  resource_group_name  = "${azurerm_resource_group.terraform-rg.name}"
  address_prefix       = "10.0.2.0/24"
}
