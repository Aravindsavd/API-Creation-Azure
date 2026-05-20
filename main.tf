# ---------------------------------------------------------------------------
# Data Sources — fetch existing Application Gateway and its components
# ---------------------------------------------------------------------------

data "azurerm_application_gateway" "agw" {
  name                = local.application_gateway_name
  resource_group_name = local.resource_group_name
}

# ---------------------------------------------------------------------------
# Application Gateway — Backend Address Pool
# ---------------------------------------------------------------------------

resource "azurerm_application_gateway_backend_address_pool" "api" {
  name                = local.backend_pool_name
  resource_group_name = local.resource_group_name
  application_gateway_name = data.azurerm_application_gateway.agw.name

  backend_addresses {
    ip_address = var.backend_vm_private_ip
  }
}

# ---------------------------------------------------------------------------
# Application Gateway — HTTP Listener (HTTPS on port 443)
# ---------------------------------------------------------------------------

resource "azurerm_application_gateway_http_listener" "api" {
  name                           = local.listener_name
  resource_group_name            = local.resource_group_name
  application_gateway_name       = data.azurerm_application_gateway.agw.name
  frontend_ip_configuration_name = "appGwPublicFrontendIp"
  frontend_port_name             = "port_443"
  protocol                       = "Https"
  host_name                      = local.listener_hostname
  ssl_certificate_name           = "wildcard.paragon-apteancloud.com"

  depends_on = [azurerm_application_gateway_backend_address_pool.api]
}

# ---------------------------------------------------------------------------
# Application Gateway — Health Probe
# ---------------------------------------------------------------------------

resource "azurerm_application_gateway_probe" "api" {
  name                                      = local.health_probe_name
  resource_group_name                       = local.resource_group_name
  application_gateway_name                  = data.azurerm_application_gateway.agw.name
  protocol                                  = "Http"
  path                                      = "/api/servicehooks/scheduledata"
  interval                                  = 30
  timeout                                   = 30
  unhealthy_threshold                       = 3
  pick_host_name_from_backend_http_settings = true

  match {
    status_code = ["200-401"]
  }

  depends_on = [azurerm_application_gateway_http_listener.api]
}

# ---------------------------------------------------------------------------
# Application Gateway — Backend HTTP Settings
# ---------------------------------------------------------------------------

resource "azurerm_application_gateway_backend_http_settings" "api" {
  name                                = local.backend_settings_name
  resource_group_name                 = local.resource_group_name
  application_gateway_name            = data.azurerm_application_gateway.agw.name
  port                                = 8023
  protocol                            = "Http"
  cookie_based_affinity               = "Disabled"
  request_timeout                     = 30
  pick_host_name_from_backend_address = true
  probe_name                          = local.health_probe_name

  depends_on = [azurerm_application_gateway_probe.api]
}

# ---------------------------------------------------------------------------
# Application Gateway — Request Routing Rule
# ---------------------------------------------------------------------------

resource "azurerm_application_gateway_request_routing_rule" "api" {
  name                       = local.rule_name
  resource_group_name        = local.resource_group_name
  application_gateway_name   = data.azurerm_application_gateway.agw.name
  rule_type                  = "Basic"
  priority                   = var.rule_priority
  http_listener_name         = local.listener_name
  backend_address_pool_name  = local.backend_pool_name
  backend_http_settings_name = local.backend_settings_name

  depends_on = [azurerm_application_gateway_backend_http_settings.api]
}

# ---------------------------------------------------------------------------
# DNS — CNAME Record in paragon.apteancloud.com zone
# ---------------------------------------------------------------------------

resource "azurerm_dns_cname_record" "api" {
  name                = local.dns_record_name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_resource_group_name
  ttl                 = 3600
  record              = "${local.dns_record_name}.paragon.apteancloud.com.cdn.cloudflare.net"
}
