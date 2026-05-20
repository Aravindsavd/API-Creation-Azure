locals {
  resource_group_name      = "rg-${var.region}-prd-pgn"
  application_gateway_name = "agw-${var.region}-prd-pgn"
  dns_resource_group_name  = "rg-westuk-prd-pgn"
  dns_zone_name            = "paragon.apteancloud.com"

  listener_hostname     = "${var.client_name}-api.paragon.apteancloud.com"
  backend_pool_name     = "beap-${var.region}-${var.environment}-pgn-${var.client_name}-api"
  listener_name         = "lst-${var.region}-${var.environment}-pgn-${var.client_name}-api"
  backend_settings_name = "htst-${var.region}-${var.environment}-pgn-${var.client_name}-api"
  health_probe_name     = "prb-${var.region}-${var.environment}-pgn-${var.client_name}-api"
  rule_name             = "fwr-${var.region}-${var.environment}-pgn-${var.client_name}-api"
  dns_record_name       = "${var.client_name}-api"
}
