terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "core"
  features {}
}

provider "random" {

}
data "azurerm_resource_group" "compute_rg" {
  name = var.rg_name
}

data "azurerm_virtual_network" "compute_vn" {
  name                = "${data.azurerm_resource_group.compute_rg.name}-network"
  resource_group_name = data.azurerm_resource_group.compute_rg.name
}

data "azurerm_subnet" "compute_sn" {
  name                 = "${data.azurerm_resource_group.compute_rg.name}-subnet"
  virtual_network_name = data.azurerm_virtual_network.compute_vn.name
  resource_group_name  = data.azurerm_resource_group.compute_rg.name
}

data "azurerm_public_ip_prefix" "compute_pip" {
  name                = "${data.azurerm_resource_group.compute_rg.name}-pip"
  resource_group_name = data.azurerm_resource_group.compute_rg.name
}

resource "random_pet" "compute_id" {
  length = 2
  keepers = {
    owner = var.vm_owner
  }

}

locals {
  resource_tags = merge(var.extra_tags, { owner = random_pet.compute_id.keepers.owner, DoNotDelete = true })
  vm_name       = "${var.vm_name_prefix}-${random_pet.compute_id.id}"
}
