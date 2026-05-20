output "client_url" {
  description = "Public URL for the client API endpoint"
  value       = "https://${local.listener_hostname}"
}

output "dns_record_fqdn" {
  description = "FQDN of the newly created DNS CNAME record"
  value       = azurerm_dns_cname_record.api.fqdn
}

output "backend_pool_name" {
  description = "Name of the Application Gateway backend pool"
  value       = azurerm_application_gateway_backend_address_pool.api.name
}

output "routing_rule_priority" {
  description = "Priority assigned to the new routing rule"
  value       = azurerm_application_gateway_request_routing_rule.api.priority
}

output "cloudflare_reminder" {
  description = "Manual step required after apply"
  value       = "ACTION REQUIRED: Create a Cloudflare A Record via SD Ticket for ${local.listener_hostname}"
}
