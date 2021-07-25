locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service          = "Elite Technology Services"
    Owner            = "EliteInfra"
    Department       = "IT"
    Company          = "EliteSolutions LLC"
    subscriptionname = "EliteResources"
    ManagedWith      = "Terraform"
  }

  network = {
    resource_group_name  = "Elite_resources_DEV"
    RG_network           = "Elite_resourcesRG"
    vnet_name            = "Vnet_development"
    RG_Vnet              = "DEVRG_vnet"
  }

  application = {
    app_name = "Jenkins Server"
    location = "eastus"
    alias    = "Dev"
    vm_name  = "jenkinsvm"
  }
}