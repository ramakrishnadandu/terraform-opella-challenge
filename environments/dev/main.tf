provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}


# 1. Resource Group
data "azurerm_resource_group" "rg" {
  name = "dev-rg"
}

# 2. VNET Module
module "vnet" {
  source              = "../../modules/vnet"
  vnet_name           = "dev-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
  subnets = [
    {
      name           = "private-subnet"
      address_prefix = "10.10.1.0/24"
    }
  ]
  tags = {
    environment = "dev"
    owner       = "opella"
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "opelladrkdevsta01"  # must be globally unique
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Allow access only from your subnet
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [
      module.vnet.subnet_ids["private-subnet"]
    ]
  }

  tags = {
    environment = "dev"
    project     = "opella"
  }
}



output "storage_account_id" {
  value = azurerm_storage_account.storage.id
}

output "subnet_id" {
  value = module.vnet.subnet_ids["private-subnet"]
}

