provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
# Prepare Base Infrastructure for Azure Windows VM's
locals {
  azure_locations = ["germanywestcentral", "eastus"]
}

module "resource_group_net" {
  for_each     = toset(local.azure_locations)
  source       = "git::https://github.com/otc-code/res-azr-rg.git?ref=v1.0.0"
  cloud_region = each.key
  config       = var.config
  custom_name  = "net"
}

module "vnet" {
  for_each                    = toset(local.azure_locations)
  depends_on                  = [module.resource_group]
  source                      = "git::https://github.com/otc-code/res-azr-vnet.git?ref=v1.1.1"
  cloud_region                = each.key
  config                      = var.config
  resource_group_name         = module.resource_group_net[each.key].resource_group_name
  create_default_sg           = true
  calculate_ipv6_private_cidr = false # Only IPv4
  subnets = {
    vm_subnet = {
      custom_name = "vm" # Only a vm subnet
    }
  }
}

# Adding NSG Rules to vnet's
module "nsg" {
  for_each                     = toset(local.azure_locations)
  source                       = "git::https://github.com/otc-code/res-azr-nsg.git?ref=v1.1.0"
  cloud_region                 = each.key
  config                       = var.config
  resource_group_name          = module.resource_group_net[each.key].resource_group_name
  attach_rules                 = true
  existing_security_group_name = module.vnet[each.key].subnets["vm_subnet"].security_group_name
  security_rules = {
    rdp = {
      name                         = "inbound_3389"
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "3389"
      source_address_prefixes      = ["0.0.0.0/0"]
      destination_address_prefixes = module.vnet[each.key].vnet_address_space
    },
    kasm = {
      name                         = "inbound_4902"
      priority                     = 101
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "4902"
      source_address_prefixes      = ["0.0.0.0/0"]
      destination_address_prefixes = module.vnet[each.key].vnet_address_space
    }
  }
}

# Creating RG's for Pools VM
module "resource_group" {
  for_each     = toset(local.azure_locations)
  source       = "git::https://github.com/otc-code/res-azr-rg.git?ref=v1.0.0"
  cloud_region = each.key
  config       = var.config
  custom_name  = "vm"
}


