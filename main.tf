terraform {
  # backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.46.0"
    }
    azuread = {
      source  = "hashicorp/azurerm"
      version = ">=1.4.0"
    }
  }
}

provider "azuread" {
  features {}
}


provider "azurerm" {
  features {}
  alias = "core"
}



locals {
  base_tags = {
    "createdBy" : var.tag_createdBy
    "managedBy" : var.tag_managedBy
    "createdAt" : var.tag_createdAt
    "lastApplyAt" : var.tag_lastApplyAt
  }
}



module "networking" {
  providers = {
    azurerm = azurerm.core
  }
  source                   = "./modules/networking"
  deployment_number        = "01"
  region                   = var.region
  tags                     = local.base_tags
  vnet_hub_address_space   = "172.16.0.0/25"
  snet_edge_address_prefix = "172.16.0.0/26"
  default_gateway_address  = "172.16.0.5"
}