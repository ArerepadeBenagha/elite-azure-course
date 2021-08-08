
# since these variables are re-used - a locals block makes this more maintainable
locals {
  frontend_port_name             = "${data.azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${data.azurerm_virtual_network.vnet.name}-feip"
}
resource "azurerm_subnet" "subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = local.network.RG_network
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}
resource "azurerm_public_ip" "publicip" {
  name                = "appgw-publicip"
  resource_group_name = local.network.RG_network
  location            = local.application.location
  allocation_method   = var.sku_tier == "WAF_v2" ? "Static" : "Dynamic"
  sku                 = var.sku_tier == "WAF_v2" ? "Standard" : "WAF_v2"
  domain_name_label   = var.domain_name_label
}
resource "azurerm_application_gateway" "app-gateway" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.rg_location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = 3
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.subnet.id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.publicip.id
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.ip_addresses
      fqdns        = backend_address_pool.value.fqdns
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = "Disabled"
      path                                = backend_http_settings.value.path
      port                                = backend_http_settings.value.is_https ? "443" : "80"
      protocol                            = backend_http_settings.value.is_https ? "Https" : "Http"
      request_timeout                     = backend_http_settings.value.request_timeout
      probe_name                          = backend_http_settings.value.probe_name
      pick_host_name_from_backend_address = true
    }
  }

  dynamic "probe" {
    for_each = var.probes
    content {
      interval                                  = 30
      name                                      = probe.value.name
      path                                      = probe.value.path
      protocol                                  = probe.value.is_https ? "Https" : "Http"
      timeout                                   = 30
      unhealthy_threshold                       = 3
      pick_host_name_from_backend_http_settings = true
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.ssl_certificate_name != null ? "https-port" : "http-port"
      protocol                       = http_listener.value.ssl_certificate_name != null ? "Https" : "Http"
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      host_name                      = http_listener.value.host_name
      require_sni                    = (http_listener.value.ssl_certificate_name != null ? http_listener.value.require_sni : null)
    }
  }

  #   dynamic "ssl_certificate" {
  #     for_each = var.ssl_certificates
  #     content {
  #       name     = ssl_certificate.value.name
  #       data     = filebase64(ssl_certificate.value.pfx_cert_filepath)
  #       password = ssl_certificate.value.pfx_cert_password
  #     }
  #   }

  // Basic Rules
  dynamic "request_routing_rule" {
    for_each = var.basic_request_routing_rules
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = "Basic"
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
    }
  }

  // Redirect Rules
  #   dynamic "request_routing_rule" {
  #     for_each = var.redirect_request_routing_rules
  #     content {
  #       name                        = request_routing_rule.value.name
  #       rule_type                   = "Basic"
  #       http_listener_name          = request_routing_rule.value.http_listener_name
  #       redirect_configuration_name = request_routing_rule.value.redirect_configuration_name
  #     }
  #   }

  // Path based rules
  #   dynamic "request_routing_rule" {
  #     for_each = var.path_based_request_routing_rules
  #     content {
  #       name               = request_routing_rule.value.name
  #       rule_type          = "PathBasedRouting"
  #       http_listener_name = request_routing_rule.value.http_listener_name
  #       url_path_map_name  = request_routing_rule.value.url_path_map_name
  #     }
  #   }

  #   dynamic "url_path_map" {
  #     for_each = var.url_path_maps
  #     content {
  #       name                               = url_path_map.value.name
  #       default_backend_http_settings_name = url_path_map.value.default_backend_http_settings_name
  #       default_backend_address_pool_name  = url_path_map.value.default_backend_address_pool_name

  #       dynamic "path_rule" {
  #         for_each = url_path_map.value.path_rules
  #         content {
  #           name                       = path_rule.value.name
  #           backend_address_pool_name  = path_rule.value.backend_address_pool_name
  #           backend_http_settings_name = path_rule.value.backend_http_settings_name
  #           paths                      = path_rule.value.paths
  #         }
  #       }
  #     }
  #   }

  dynamic "redirect_configuration" {
    for_each = var.redirect_configurations
    content {
      name                 = redirect_configuration.value.name
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  #
  # Security
  #

  dynamic "waf_configuration" {
    for_each = local.enable_waf ? ["fake"] : []
    content {
      enabled                  = var.enable_waf
      file_upload_limit_mb     = coalesce(var.file_upload_limit_mb, 100)
      firewall_mode            = coalesce(var.waf_mode, "Prevention")
      max_request_body_size_kb = coalesce(var.max_request_body_size_kb, 128)
      request_body_check       = var.request_body_check
      rule_set_type            = var.rule_set_type
      rule_set_version         = var.rule_set_version

      dynamic "disabled_rule_group" {
        for_each = local.disabled_rule_group_settings
        content {
          rule_group_name = lookup(disabled_rule_group.value, "rule_group_name", null)
          rules           = lookup(disabled_rule_group.value, "rules", null)
        }
      }

      dynamic "exclusion" {
        for_each = var.waf_exclusion_settings
        content {
          match_variable          = lookup(exclusion.value, "match_variable", null)
          selector                = lookup(exclusion.value, "selector", null)
          selector_match_operator = lookup(exclusion.value, "selector_match_operator", null)
        }
      }
    }
  }
}

// Allows dynamic app gateway IP to be used.
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip#ip_address
data "azurerm_public_ip" "publicip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = local.network.RG_network
  depends_on          = [azurerm_application_gateway.app-gateway]
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "dev_beap" {
  network_interface_id    = data.azurerm_network_interface.dev_nic.id
  ip_configuration_name   = local.application.alias
  backend_address_pool_id = azurerm_application_gateway.app-gateway.backend_address_pool[0].id
}