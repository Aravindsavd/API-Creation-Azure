# Paragon API Endpoint — Azure Application Gateway (Terraform)

Terraform equivalent of the `Add-ParagonAPIEndpoint.ps1` PowerShell script.  
Automates creation of an API endpoint on the Azure Application Gateway and a CNAME record in the `paragon.apteancloud.com` DNS zone.

Applicable for all Paragon regions: **eastus2**, **westuk**, **anze**.

---

## 📁 Files

```
paragon-agw-terraform/
├── provider.tf       # AzureRM provider + Terraform version constraints
├── variables.tf      # Input variable definitions with validation
├── locals.tf         # Naming convention locals (matches PS script exactly)
├── main.tf           # All AGW and DNS resources
├── outputs.tf        # Client URL, DNS FQDN, Cloudflare reminder
├── example.tfvars    # Template — copy to terraform.tfvars before running
└── README.md
```

---

## 🔁 PowerShell → Terraform Mapping

| PowerShell Step | Terraform Resource |
|---|---|
| `Add-AzApplicationGatewayBackendAddressPool` | `azurerm_application_gateway_backend_address_pool` |
| `Add-AzApplicationGatewayHttpListener` | `azurerm_application_gateway_http_listener` |
| `Add-AzApplicationGatewayProbeConfig` | `azurerm_application_gateway_probe` |
| `Add-AzApplicationGatewayBackendHttpSetting` | `azurerm_application_gateway_backend_http_settings` |
| `Add-AzApplicationGatewayRequestRoutingRule` | `azurerm_application_gateway_request_routing_rule` |
| `New-AzDnsRecordSet` (CNAME) | `azurerm_dns_cname_record` |

---

## 🚀 Usage

### 1. Configure Variables

```bash
cp example.tfvars terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Initialise

```bash
terraform init
```

### 3. Plan

```bash
terraform plan -var-file="terraform.tfvars"
```

### 4. Apply

```bash
terraform apply -var-file="terraform.tfvars"
```

---

## 📥 Input Variables

| Variable | Description | Allowed Values |
|----------|-------------|----------------|
| `client_name` | Client name used in naming and DNS | Any string |
| `region` | Azure region shortname | `eastus2`, `westuk`, `anze` |
| `environment` | Deployment environment | `prd`, `uat` |
| `backend_vm_private_ip` | Private IP of the backend VM | Valid IP string |
| `rule_priority` | Unique priority for the routing rule | Integer (check existing rules first) |

---

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `client_url` | Final HTTPS URL for the client API |
| `dns_record_fqdn` | FQDN of the new CNAME record |
| `backend_pool_name` | Name of the created backend pool |
| `routing_rule_priority` | Priority assigned to the routing rule |
| `cloudflare_reminder` | Reminder to raise SD ticket for Cloudflare A Record |

---

## ⚠️ Important Notes

- **Rule Priority** must be unique across all existing routing rules on the Application Gateway. Check current rules before setting `rule_priority`, then increment by 1 from the highest existing value.
- **Cloudflare A Record** is NOT created by this Terraform — it still requires a manual SD Ticket, as flagged in the `cloudflare_reminder` output.
- **Subscription ID** in `provider.tf` is set to `a-prod-002` — replace with your actual subscription GUID if needed.
- The DNS CNAME is always created in `rg-westuk-prd-pgn` regardless of the region, matching the original script behaviour.

---

## 🗑️ Destroying a Client Endpoint

To remove all resources created for a client:

```bash
terraform destroy -var-file="terraform.tfvars"
```

> Remember to also remove the Cloudflare A Record manually via SD Ticket.
