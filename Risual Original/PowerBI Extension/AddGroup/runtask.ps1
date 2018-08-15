#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
[CmdletBinding()]

param()
Trace-VstsEnteringInvocation $MyInvocation
# Import the modules we require

#region Import Modules
Import-Module  "${PSScriptRoot}\ps_modules\VstsTaskSdk\VstsTaskSdk.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\Library.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\GroupOperations.psm1" -verbose
#endregion Import Modules

Write-Host "Start of Main Function"
Write-Host ""


#region Load Parameters from Task 	
Write-host "Get the Parameters"
$PowerBIAPI = Get-VstsInput -Name PowerBIAPI -Require

Get-VstsEndpoint $PowerBIAPI

$Api = Get-Endpoint -Name $PowerBIAPI -require
$EndpointUrl = $Api.URL

# Get the API Variables
$API = Get-TaskVariableinfo 
Write-host "API ########################>"



$Username = Get-TaskVariable -Name APIUsername -Require
$Password = Get-TaskVariable -Name APIPassword -Require
$GroupName = Get-VstsInput -Name GroupName -Require
$clientId = Get-VstsInput -Name clientId -Require


#endregion Load Parameters from Task 	

##############################################

#region Validate Parameters
#check for a valid orgName
    if([string]::IsNullOrWhiteSpace($orgName)){$orgName = "myorg"} 
#endregion Validate Parameters



#region Get Endpoint
Write-output "Getting PowerBI API Name"
$APIName = Get-VstsInput -Name "PowerBIAPI"
#endregion Get Endpoint

#region Get Token
	$resourceUrl = "https://analysis.windows.net/powerbi/api"
	$token = Get-AADToken -username $userName -Password $passWord -clientId $clientId -resource $resourceUrl -Verbose
#endregion Get Token	

#region check for existing group
Write-Host "Checking if the Group $GroupName already exists"
	$Group = Get-PBIGroup -GroupName $GroupName -AccessToken $token 

#endregion check for existing group
Write-Output "Entering Function Add-PBIGroup"
	$Status = Add-PBIGroup -GroupName $GroupName -AccessToken $token 

Write-Output "Returned from Function Add-PBIGroup"
Write-output $Status

Write-Host ""
Write-Host "End of Main Function"
