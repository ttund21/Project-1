resource "azurerm_public_ip" "terraform-publicip" {
  name                = "terraform-puclicip"
  location            = "${azurerm_resource_group.terraform-rg.location}"
  resource_group_name = "${azurerm_resource_group.terraform-rg.name}"
  allocation_method   = "Static"
  domain_name_label   = "terraform"
}
