# Prepare Base Infrastructure for Azure Windows VM's
locals {
  azure_locations=["germanywestcentral"]
}

module "resource_group" {
  for_each = toset(local.azure_locations)
  source       = "git::https://github.com/otc-code/res-azr-rg.git?ref=v1.0.0"
  cloud_region = each.key
  config       = var.config
}



