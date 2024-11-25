provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
# Prepare Base Infrastructure for Azure Windows VM's
locals {
  azure_locations=["germanywestcentral","eastus"]
}

module "resource_group" {
  for_each = toset(local.azure_locations)
  source       = "git::https://github.com/otc-code/res-azr-rg.git?ref=v1.0.0"
  cloud_region = each.key
  config       = var.config
}

module "vnet" {
  for_each = toset(local.azure_locations)
  depends_on          = [module.resource_group]
  source              = "git:https://github.com/otc-code/res-azr-vnet.git?ref=v1.1.1"
  cloud_region        = each.key
  config              = var.config
  resource_group_name = module.resource_group[each.key].resource_group_name
  create_default_sg   = true
  subnets = {
      sub1 = {
      custom_name = "vm" # Only a vm subnet
    }
  }
}



