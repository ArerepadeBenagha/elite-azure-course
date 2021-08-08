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
    resource_group_name = "Elite_resources_DEV"
    RG_network          = "Elite_resourcesRG"
    vnet_name           = "Vnet_development"
    RG_Vnet             = "DEVRG_vnet"
  }

  application = {
    app_name = "Jenkins Server"
    location = "eastus"
    alias    = "Dev"
    vm_name  = "jenkinsvm"
  }

  enable_waf = var.sku == "WAF_v2" ? true : false

  # https://docs.microsoft.com/fr-fr/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway#exposing-the-developer-portal-externally-through-application-gateway
  disabled_rule_group_settings_dev_portal = [
    {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      rules = [
        942100,
        942200,
        942110,
        942180,
        942260,
        942340,
        942370,
        942430,
        942440
      ]
    },
    {
      rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
      rules = [
        920300,
        920330
      ]
    },
    {
      rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
      rules = [
        931130
      ]
    }
  ]

  disabled_rule_group_settings = var.disable_waf_rules_for_dev_portal ? concat(local.disabled_rule_group_settings_dev_portal, var.disabled_rule_group_settings) : var.disabled_rule_group_settings
}