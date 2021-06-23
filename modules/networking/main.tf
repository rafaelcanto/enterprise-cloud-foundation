




module "hub_01" {
  source = "./modules/hub"

  region                   = var.region
  deployment_number        = var.deployment_number
  snet_edge_address_prefix = var.snet_edge_address_prefix
  vnet_hub_address_space   = var.vnet_hub_address_space
  tags                     = var.tags
  vnet_example_default_id  = module.spoke_default_example.vnet_id
  vnet_example_cni_id      = module.spoke_cni_example.vnet_id
}


module "spoke_default_example" {
  source                          = "./modules/spoke_default"
  region                          = var.region
  deployment_number               = var.deployment_number
  vnet_address_space              = "172.16.1.0/25"
  snet_application_address_prefix = "172.16.1.0/27"
  snet_database_address_prefix    = "172.16.1.32/27"
  shortApplicationName            = "example1"
  fullApplicationName             = "example1Application"
  vnet_hub_id                     = module.hub_01.vnet_id
  default_gateway_address         = var.default_gateway_address
  tags                            = var.tags
}

module "spoke_cni_example" {
  source                  = "./modules/spoke_cni"
  region                  = var.region
  deployment_number       = var.deployment_number
  vnet_address_space      = "172.17.0.0/22"
  snet_cni_address_prefix = "172.17.0.0/22"
  shortApplicationName    = "example2"
  fullApplicationName     = "example2Application"
  vnet_hub_id             = module.hub_01.vnet_id
  default_gateway_address = var.default_gateway_address

  tags = var.tags
}