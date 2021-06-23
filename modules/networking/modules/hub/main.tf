resource "azurerm_resource_group" "main" {
  name     = "rg-hubnetworking-${var.region}-${var.deployment_number}"
  location = var.region
}


# VNETs
resource "azurerm_virtual_network" "main" {
  name                = "vnet-hub-${var.region}-${var.deployment_number}"
  location            = var.region
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_hub_address_space]
  tags                = var.tags
}

# Subnets
resource "azurerm_subnet" "edge" {
  name                 = "snet-edge"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.snet_edge_address_prefix]
}

# Peerings
resource "azurerm_virtual_network_peering" "example_default" {
  name                         = "peer-example-default"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.main.name
  remote_virtual_network_id    = var.vnet_example_default_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "example_cni" {
  name                         = "peer-example-cni"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.main.name
  remote_virtual_network_id    = var.vnet_example_cni_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}