terraform {
  backend "local" {}
}

provider "azurerm" {
  features {}
}

locals {
  location    = "westeurope"
  environment = "test"
  module      = "app-007"
  slot        = "shared"
}

module "rg" {
  source      = "git@github.com:anizamutdinov-tfm/azurerm-resource-group.git"
  location    = local.location
  environment = local.environment
  module      = local.module
  slot        = local.slot
}

module "vnet" {
  source              = "git@github.com:anizamutdinov-tfm/azurerm-virtual-network.git"
  depends_on          = [module.rg]
  resource_group_name = module.rg.resource_group_name
  environment         = local.environment
  module              = local.module
  slot                = local.slot
  vnet_cidr           = ["172.16.0.0/16"]
}

module "subnet" {
  source               = "git@github.com:anizamutdinov-tfm/azurerm-subnet.git"
  depends_on           = [module.rg, module.vnet]
  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  environment          = local.environment
  module               = local.module
  slot                 = local.slot
  subnet_cidr          = [cidrsubnet(module.vnet.virtual_network_cidr[0], 13, 0)]
}

module "vm" {
  source              = "git@github.com:anizamutdinov-tfm/azurerm-virtual-machine.git"
  depends_on          = [module.rg, module.subnet]
  resource_group_name = module.rg.resource_group_name
  subnet_id           = module.subnet.subnet_id
  environment         = local.environment
  module              = local.module
  slot                = local.slot
}

module "vm_start_stop" {
  source              = "../../"
  depends_on          = [module.rg, module.vm]
  resource_group_name = module.rg.resource_group_name
  vm_name             = module.vm.vm_name
  environment         = local.environment
  module              = local.module
  slot                = local.slot
  start_schedule = {
    frequency = "Minute"
    interval  = 15
    start     = timeadd(timestamp(), "10m")
  }
  stop_schedule = {
    frequency = "Minute"
    interval  = 15
    start     = timeadd(timestamp(), "5m")
  }
}