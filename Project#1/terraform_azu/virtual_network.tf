resource "azurerm_virtual_network" "terraform-vnet" {
  name                = "terraform-vnet"
  location            = "${azurerm_resource_group.terraform-rg.location}"
  resource_group_name = "${azurerm_resource_group.terraform-rg.name}"
  address_space       = ["10.0.0.0/16"]
}
