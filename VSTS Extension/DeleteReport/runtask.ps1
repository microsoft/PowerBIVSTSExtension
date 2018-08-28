#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
[CmdletBinding()]

param()
Trace-VstsEnteringInvocation $MyInvocation
Import-Module  "${PSScriptRoot}\ps_modules\VstsTaskSdk\VstsTaskSdk.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\Library.psm1" -verbose

	Write-Host "Start of Main Function"
	Write-Host 


	
Write-host "Get the Parameters"
$PowerBIAPI = Get-VstsInput -Name PowerBIAPI -Require

Get-VstsEndpoint $PowerBIAPI

$Api = Get-Endpoint -Name $PowerBIAPI -require
$EndpointUrl = $Api.URL

Write-Host "PowerBIAPI::$PowerBIAPI" 
Write-Host "Endpoint::$Api" 
Write-Host "URL::$EndpointUrl" 

$API = Get-TaskVariableinfo 
Write-host "API ########################>"
Write-host	$API


$Username = Get-TaskVariable -Name APIUsername -Require
$Password = Get-TaskVariable -Name APIPassword -Require
$GroupName = Get-VstsInput -Name GroupName -Require
$ReportName = Get-VstsInput -Name ReportName -Require
$clientId = Get-VstsInput -Name clientId -Require


Write-Host "Username: $Username"
Write-Host "Password: $Password"

##############################################

#region Validate Parameters
#check for a valid orgName
    if([string]::IsNullOrWhiteSpace($orgName)){$orgName = "myorg"} 
    $tenantName = "398a6ed0-01ba-4c7b-9c28-2b6f95c50232"
    #$clientId = "1fe165cd-a395-4fde-ab05-81b073ec773b"

#endregion Validate Parameters



#region Get Endpoint
Write-output "Getting PowerBI API Name"
$APIName = Get-VstsInput -Name "PowerBIAPI"
write-output $item	

#endregion Get Endpoint

write-host "GetAuthToken2 -TenantName $tenantName -clientId "1fe165cd-a395-4fde-ab05-81b073ec773b" -User $Username -Password $Password"

#    $token = GetAuthToken2 -TenantName $tenantName -clientId "1fe165cd-a395-4fde-ab05-81b073ec773b" -User $Username -Password $Password
    # from other script
	$resourceUrl = "https://analysis.windows.net/powerbi/api"
	$token = Get-AADToken -username $userName -Password $passWord -clientId $clientId -resource $resourceUrl -Verbose
	
	#if($token.AccessToken)
 #   {
	#	write-host "token"
	#	write-host $token
	#}
	$token
#region CreateHeader
#    $authHeader = @{
#		            'Content-Type'='application/json'
#	                'Authorization'= $token.CreateAuthorizationHeader()
#                    }
	$authHeader = @{
					'Content-Type'='application/json'
					"Authorization" = "Bearer $($authResult)"
					}

 #  $uri = "https://api.powerbi.com/v1.0/" + $orgName + "/dashboards"
 #	$url =$endpoint.url
    $uri =   # "$($EndpointUrl)/myorg/groups"

    Write-Host $uri


#region HttpRequest
#try
#{
#    $response = Invoke-RestMethod -Uri $uri -Method get -Headers $authHeader  -verbose #-ContentType 'multipart/form-data' -Verbose
#        $response|Out-GridView
#}
#catch
#{
#write
#}
#endregion HttpRequest
write-output "Getting Groups"

Write-output "EndpointURL:: $($EndpointUrl)"
	$url = $EndpointUrl
    $uri =   "$($url)/myorg/groups"

$output = Delete-PowerBIReport -GroupName $GroupName -ReportName $ReportName -AccessToken $AccessToken