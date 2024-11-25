output "vnet" {
  value = module.vnet["eastus"].subnets["vm_subnet"].security_group_name
  description= "The created vNets"
}