terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "1.35.0"
    }
  }
}
resource "azurerm_resource_group" "farenow" {
  name     = "farenow-travel"
  location = var.location
}
