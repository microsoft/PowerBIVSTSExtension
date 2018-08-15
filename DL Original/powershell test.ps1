#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
#[CmdletBinding(DefaultParameterSetName = 'None')]
#param(
#    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $orgName,
#    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $filepath,
#    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $datasetDisplayName,
#    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $nameConflict,
#    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $PreferClientRouting,
#    [string]$replaceRegex,
#    [string]$buildNumber = $env:BUILD_BUILDNUMBER
#)
$orgName = "davidlustyoutlook.onmicrosoft.com"
$filepath = "C:\test.txt"
$datasetDisplayName = "testing"
$nameConflict = "Overwrite"
$PreferClientRouting = $false

function GetAuthToken
{
  param
  (
    [Parameter(Mandatory=$true)]
    $TenantName
    #WriteHost $TenantName
  )
  $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
  $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
  [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
  [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
  $clientId = "2f1610ce-f193-4d68-9c9a-77d4fb26c58f" 
  $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
  $resourceAppIdURI = "https://graph.windows.net"
  $authority = "https://login.windows.net/$TenantName"
  $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
  $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId,$redirectUri, "Auto")
  return $authResult
}
$token = GetAuthToken -TenantName "davidlustyoutlook.onmicrosoft.com"
Write-Host "test"
$authHeader = @{
  'Content-Type'='application\json'
  'Authorization'=$token.CreateAuthorizationHeader()
  }
  Write-Host "test2"


$uri = "https://api.powerbi.com/v1.0/" + $orgName + "/groups/me/imports?datasetDisplayName=" + $datasetDisplayName +"&nameConflict=" + $nameConflict + "&PreferClientRouting=" + $PreferClientRouting
Write-Host $uri
$response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Infile $filepath -ContentType 'multipart/form-data'

