

resource "azurerm_resource_group" "main" {
  name     = "rg-networking-${var.region}-${var.deployment_number}"
  location = var.region
}


resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.shortApplicationName}-${var.region}-${var.deployment_number}"
  location            = var.region
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# Subnets
resource "azurerm_subnet" "cni" {
  name                 = "snet-cni"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.snet_cni_address_prefix]
}

# Peerings
resource "azurerm_virtual_network_peering" "hub" {
  name                         = "peer-hub"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.main.name
  remote_virtual_network_id    = var.vnet_hub_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}


# Routing
resource "azurerm_route_table" "default" {
  name                = "udr-${var.shortApplicationName}-default"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_route" "default" {
  name                   = "route-www"
  resource_group_name    = azurerm_resource_group.main.name
  route_table_name       = azurerm_route_table.default.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.default_gateway_address
}

resource "azurerm_subnet_route_table_association" "cni" {
  subnet_id      = azurerm_subnet.cni.id
  route_table_id = azurerm_route_table.default.id
}

#NSGs
resource "azurerm_network_security_group" "default" {
  name                = "nsg-${var.shortApplicationName}-${var.region}-${var.deployment_number}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "allow_example" {
  name                        = "AllowExample"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "1.2.3.4"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.default.name
}

resource "azurerm_subnet_network_security_group_association" "cni" {
  subnet_id                 = azurerm_subnet.cni.id
  network_security_group_id = azurerm_network_security_group.default.id
}