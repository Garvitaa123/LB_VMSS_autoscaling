# LB Public IP 
resource "azurerm_public_ip" "lb" {
  name                = "${var.prefix}-lb-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = length(var.availability_zones) > 0 ? var.availability_zones : null
}
