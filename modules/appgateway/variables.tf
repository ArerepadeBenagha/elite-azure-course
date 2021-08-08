// Required
variable "rg_name" {
  description = "Name of the resource group to place App Gateway in."
}
variable "rg_location" {
  description = "Location of the resource group to place App Gateway in."
}
variable "name" {
  description = "Name of App Gateway"
}


// Optional
variable "backend_address_pools" {
  description = "List of backend address pools."
  type = list(object({
    name         = string
    ip_addresses = list(string)
    fqdns        = list(string)
  }))
}
variable "backend_http_settings" {
  description = "List of backend HTTP settings."
  type = list(object({
    name                                      = string
    path                                      = string
    is_https                                  = bool
    request_timeout                           = string
    probe_name                                = string
    pick_host_name_from_backend_http_settings = bool
  }))
}
variable "http_listeners" {
  description = "List of HTTP/HTTPS listeners. HTTPS listeners require an SSL Certificate object."
  type = list(object({
    name                 = string
    ssl_certificate_name = string
    host_name            = string
    require_sni          = bool
  }))
}
variable "basic_request_routing_rules" {
  description = "Request routing rules to be used for listeners."
  type = list(object({
    name                       = string
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
  }))
  default = []
}
variable "redirect_request_routing_rules" {
  description = "Request routing rules to be used for listeners."
  type = list(object({
    name                        = string
    http_listener_name          = string
    redirect_configuration_name = string
  }))
  default = []
}
# variable "path_based_request_routing_rules" {
#   description = "Request routing rules to be used for listeners."
#   type = list(object({
#     name               = string
#     http_listener_name = string
#     url_path_map_name  = string
#   }))
#   default = []
# }

variable "sku_name" {
  description = "Name of App Gateway SKU. Options include Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2"
  default     = "WAF_v2"
}
variable "sku_tier" {
  description = "Tier of App Gateway SKU. Options include Standard, Standard_v2, WAF and WAF_v2"
  default     = "WAF_v2"
}
variable "probes" {
  description = "Health probes used to test backend health."
  default     = []
  type = list(object({
    name                                      = string
    path                                      = string
    is_https                                  = bool
    pick_host_name_from_backend_http_settings = bool
  }))
}
# variable "url_path_maps" {
#   description = "URL path maps associated to path-based rules."
#   default     = []
#   type = list(object({
#     name                               = string
#     default_backend_http_settings_name = string
#     default_backend_address_pool_name  = string
#     path_rules = list(object({
#       name                       = string
#       backend_address_pool_name  = string
#       backend_http_settings_name = string
#       paths                      = list(string)
#     }))
#   }))
# }

variable "domain_name_label" {
  description = "Domain name label for Public IP created."
  default     = null
}

variable "ips_allowed" {
  description = "A list of IP addresses to allow to connect to App Gateway."
  default     = []
  type = list(object({
    name         = string
    priority     = number
    ip_addresses = string
  }))
}

variable "redirect_configurations" {
  description = "A collection of redirect configurations."
  default     = []
  type = list(object({
    name                 = string
    redirect_type        = string
    target_listener_name = string
    target_url           = string
    include_path         = bool
    include_query_string = bool
  }))
}
### WAF

variable "enable_waf" {
  description = "Boolean to enable WAF."
  type        = bool
  default     = true
}

variable "file_upload_limit_mb" {
  description = " The File Upload Limit in MB. Accepted values are in the range 1MB to 500MB. Defaults to 100MB."
  type        = number
  default     = 100
}

variable "waf_mode" {
  description = "The Web Application Firewall Mode. Possible values are Detection and Prevention."
  type        = string
  default     = "Prevention"
}

variable "max_request_body_size_kb" {
  description = "The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB."
  type        = number
  default     = 128
}

variable "request_body_check" {
  description = "Is Request Body Inspection enabled?"
  type        = bool
  default     = true
}

variable "rule_set_type" {
  description = "The Type of the Rule Set used for this Web Application Firewall."
  type        = string
  default     = "OWASP"
}

variable "rule_set_version" {
  description = "The Version of the Rule Set used for this Web Application Firewall. Possible values are 2.2.9, 3.0, and 3.1."
  type        = number
  default     = 3.1
}

variable "disabled_rule_group_settings" {
  description = "The rule group where specific rules should be disabled. Accepted values can be found here: https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html#rule_group_name"
  type = list(object({
    rule_group_name = string
    rules           = list(string)
  }))
  default = []
}

variable "disable_waf_rules_for_dev_portal" {
  description = "Whether to disable some WAF rules if the APIM developer portal is hosted behind this Application Gateway. See locals.tf for the documentation link"
  type        = bool
  default     = false
}

variable "waf_exclusion_settings" {
  description = "WAF exclusion rules to exclude header, cookie or GET argument. More informations on: https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html#match_variable"
  type        = list(map(string))
  default     = []
}
variable "sku" {
  description = "The Name of the SKU to use for this Application Gateway. Possible values are Standard_v2 and WAF_v2."
  type        = string
  default     = "WAF_v2"
}