# Define your variables
$firewallPassword = "Password1"
$CompanyName = "This is the First Company"
$PublicIP = "1.1.1.1"


# Disable SSL Certification check
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
public bool CheckValidationResult(
ServicePoint srvPoint, X509Certificate certificate,
WebRequest request, int certificateProblem) {
return true;
}
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


# Create the login request and store the csrftoken
$headers = @{}
$headers.Add("Content-Type", "text/plain")
$body = "username=admin&secretkey=$firewallPassword&ajax=1"
$response = Invoke-WebRequest -Method Post -Uri "https://192.168.1.99/logincheck" -Headers $headers -Body $body -SessionVariable "MySession"

$rawContent = $response.RawContent.ToString()
if ($rawContent -match 'ccsrftoken="(.*?)"') {
    $ccsrftoken = $Matches[1]
    Write-Host "ccsrftoken value: $ccsrftoken"
} else {
    Write-Host "ccsrftoken not found!"
}

$headers.Add("X-CSRFTOKEN", $CCSRFTOKEN)


# Create a new address for the client
$body2 = @"
{
    "name": "$CompanyName",
    "subnet": "$PublicIP/32",
    "color": "0"
}
"@

$response2 = Invoke-WebRequest -Method Post -Uri "https://192.168.1.99/api/v2/cmdb/firewall/address" -Headers $headers -Body $body2 -UseBasicParsing -Websession $Mysession



# Add the newly created address to the "External_Client_Firewall_Radius" group
$body3 = @"
{
    "name": "$CompanyName"
}
"@

$response3 = Invoke-WebRequest -Method Post -Uri "https://192.168.1.99/api/v2/cmdb/firewall/addrgrp/External_Client_Firewall_Radius/member" -Headers $headers -Body $body3 -UseBasicParsing -Websession $Mysession

