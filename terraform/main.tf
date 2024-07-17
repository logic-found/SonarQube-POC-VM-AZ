terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "rg-devops"
  location = "Central India"
  tags = {
    env : "devops",
    application_name = var.project_name
  }
}
