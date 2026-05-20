# Example: copy to terraform.tfvars and fill in values before running

client_name           = "clientname"       # e.g. "acmecorp"
region                = "eastus2"          # eastus2 | westuk | anze
environment           = "prd"              # prd | uat
backend_vm_private_ip = "10.x.x.x"        # Private IP of the backend VM
rule_priority         = 110                # Must be unique; check existing rules and increment
