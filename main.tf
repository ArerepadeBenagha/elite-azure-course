terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.59.0"
    }
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "farenow" {
  name     = "farenow-travel"
  location = var.location
}

########## -----------------------------#
module "azure-bastion" {
  source = "./modules/azure-network/"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = "farenow-travel"
  virtual_network_name = "dev"
  location             = "EAST US"

  # Azure bastion server requireemnts
  azure_bastion_service_name          = "mybastion-service"
  azure_bastion_subnet_address_prefix = ["10.0.1.0/24"]

  # Adding TAG's to your Azure resources (Required)
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}