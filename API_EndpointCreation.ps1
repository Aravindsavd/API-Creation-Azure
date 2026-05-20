#MohanKumarKannan - 19/03/2025 - This script will automate Paragon API Endpoint creation on Azure Application Gateway and creates Record set on DNS Zone
#Applicable for all Region within Paragon AGW's
Connect-AzAccount
Set-AzContext "Domain name" #change manually
$clientname = Read-Host "Enter the Client Name"
$region = Read-Host "Enter the Region (eastus2 or westuk or anze - only)"
$environment = Read-Host "Enter the Environment (prd or uat)"
$backendpoolmachineip = Read-Host "Enter the Backend VM Private IP"
$listnerhostname = "$clientname-api.paragon.apteancloud.com"
$backendpoolname = "beap-$region-$environment-$clientname-api"
$listnername = "lst-$region-$environment-$clientname-api"
$backendsettingsname = "htst-$region-$environment-$clientname-api"
$healthprobename = "prb-$region-$environment-$clientname-api"
$rulename = "fwr-$region-$environment--$clientname-api"
$applicationgatewayname = "agw-$region-prd"
$resourcegroupname = "rg-$region-prd"
$dnsrecordname = "$clientname-api"

$appgateway = Get-AzApplicationGateway -Name $applicationgatewayname -ResourceGroupName $resourcegroupname
$sslCert = Get-AzApplicationGatewaySslCertificate -ApplicationGateway $appgateway -Name "wildcard.cloud.com" #choose certificate
$frontendipconfig = Get-AzApplicationGatewayFrontendIPConfig -Name "appGwPublicFrontendIp" -ApplicationGateway $appgateway
$frontendportconfig = Get-AzApplicationGatewayFrontendPort -ApplicationGateway $appgateway -Name "port_443"

# Add Backend Pool
$newbackendaddresspool = Add-AzApplicationGatewayBackendAddressPool -ApplicationGateway $appgateway -Name $backendpoolname -BackendIPAddresses $backendpoolmachineip
Set-AzApplicationGateway -ApplicationGateway $appgateway

# Add Listener
$newlistner = Add-AzApplicationGatewayHttpListener -ApplicationGateway $appgateway -Name $listnername -FrontendIPConfiguration $frontendipconfig -FrontendPort $frontendportconfig -HostName $listnerhostname -Protocol Https -SslCertificate $sslCert
Set-AzApplicationGateway -ApplicationGateway $appgateway


# Add Health Probe
$newhealthprobe = Add-AzApplicationGatewayProbeConfig `
    -ApplicationGateway $appgateway `
    -Name $healthprobename `
    -Protocol Http `
    -PickHostNameFromBackendHttpSettings `
    -Path "/api/servicehooks/scheduledata" `
    -Interval 30 `
    -Timeout 30 `
    -UnhealthyThreshold 3 `
    -Match @{StatusCodes=@("200-401")}
Set-AzApplicationGateway -ApplicationGateway $appgateway




#Get All IDs 
$newlistnerid = (Get-AzApplicationGatewayHttpListener -Name $listnername -ApplicationGateway $appgateway).Id
$newbackendaddresspoolid = (Get-AzApplicationGatewayBackendAddressPool -Name $backendpoolname -ApplicationGateway $appgateway).Id
$newhealthprobeid = (Get-AzApplicationGatewayProbeConfig -Name $healthprobename -ApplicationGateway $appgateway).Id

#Set Priority for Rule
$getrulelastpriority = (Get-AzApplicationGatewayRequestRoutingRule -ApplicationGateway $appgateway).Priority | Sort-Object -Descending | Select-Object -First 1
$priority = $getrulelastpriority + 1


# Add Backend HTTP Settings 
$newbackendsettings = Add-AzApplicationGatewayBackendHttpSetting -ApplicationGateway $appgateway -Name $backendsettingsname -Port 8023 -Protocol Http -CookieBasedAffinity Disabled -RequestTimeout 30 -PickHostNameFromBackendAddress -ProbeId $newhealthprobeid 
Set-AzApplicationGateway -ApplicationGateway $appgateway

#Get Backend Setting ID
$newbackendsettingsid = (Get-AzApplicationGatewayBackendHttpSetting -Name $backendsettingsname -ApplicationGateway $appgateway).Id

# Add Routing Rule
$newrule = Add-AzApplicationGatewayRequestRoutingRule `
    -ApplicationGateway $appgateway `
    -Name $rulename `
    -HttpListenerId $newlistnerid `
    -RuleType Basic `
    -Priority $priority `
    -BackendHttpSettingsId $newbackendsettingsid -BackendAddressPoolId $newbackendaddresspoolid
Set-AzApplicationGateway -ApplicationGateway $appgateway


#Use Following to Remove locally created objects before updating app gateway
#Get-AzApplicationGatewayRequestRoutingRule -Name $rulename -ApplicationGateway $appgateway
#Remove-AzApplicationGatewayRequestRoutingRule -Name $rulename -ApplicationGateway $appgateway


#Create a DNS Record Set in the paragon.apteancloud.com Zone
$Records = New-AzDnsRecordConfig -Cname "$dnsrecordname.paragon.apteancloud.com.cdn.cloudflare.net"
$RecordSet = New-AzDnsRecordSet -Name $dnsrecordname -RecordType CNAME -ResourceGroupName "rg-westuk-prd"  -TTL 3600 -ZoneName "paragon.apteancloud.com" -DnsRecords $Records

Write-Host "Application Gateway is now updated for $clientname and New DNS Record Created as below"
Write-Host $RecordSet.Records
Write-Host "Client URL will be https://$dnsrecordname.cloud.com" #change with correct dns name
             






