provider "azurerm" {
  features {}

  subscription_id = "abb518ec-f0fe-4020-aac8-fe23e295f6d0"
  client_id       = "20899878-9c8f-42a8-80cd-2d28d9db905d"
  client_secret   = "e.c8Q~7wpijFv~f0kCcoaJ~FztEE-9UySSF3Hdz_"
  tenant_id       = "063727cb-266f-42e0-ae33-8c7db0495339"
}
# Resource Group
resource "azurerm_resource_group" "campusspace" {
  name     = "rg-campusspace-eastasia"
  location = var.location
}

# App Service Plan (Premium v2)
resource "azurerm_app_service_plan" "campusspace_plan" {
  name                = "asp-campusspace-premiumv2"
  location            = azurerm_resource_group.campusspace.location
  resource_group_name = azurerm_resource_group.campusspace.name
  sku {
    tier = "Standard"
    size = "S1"
  }
  maximum_elastic_worker_count = 3
}


# Blob Storage (GRS)
resource "azurerm_storage_account" "campusspace_storage" {
  name                     = "campusspacestoragedev001"
  resource_group_name      = azurerm_resource_group.campusspace.name
  location                 = azurerm_resource_group.campusspace.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "dev"
    project     = "ems"
  }
}

# Blob Container for media
resource "azurerm_storage_container" "media" {
  name                  = "eventmedia"
  storage_account_name  = azurerm_storage_account.campusspace_storage.name
  container_access_type = "private"
}
