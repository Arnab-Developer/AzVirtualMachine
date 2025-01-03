terraform {
  required_version = "1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
  cloud {
    organization = ""

    workspaces {
      name = ""
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  application_name = "appjanone"
  environment_name = "dev"
  location         = "North Europe"
}

module "resource_group" {
  source           = "./modules/resource_group"
  application_name = local.application_name
  environment_name = local.environment_name
  location         = local.location
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  application_name    = local.application_name
  environment_name    = local.environment_name
  location            = local.location
  resource_group_name = module.resource_group.name
}

module "virtual_machine" {
  source              = "./modules/virtual_machine"
  application_name    = local.application_name
  environment_name    = local.environment_name
  location            = local.location
  resource_group_name = module.resource_group.name
  subnet_id           = module.virtual_network.subnet_id
}
