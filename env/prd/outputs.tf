output "vnet" {
  value = module.vnet["eastus"].subnets["vm_subnet"]
  description= "The created vNets"
}