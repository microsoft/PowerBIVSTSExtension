#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
[CmdletBinding()]

param()
Trace-VstsEnteringInvocation $MyInvocation
Import-Module  "${PSScriptRoot}\ps_modules\VstsTaskSdk\VstsTaskSdk.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\Library.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\DatasetOperations.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\GroupOperations.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\ReportOperations.psm1" -verbose
	
Write-Host "Start of Main Function"
Write-Host ""

## Get the parameters
	
Write-host "Get the Parameters"
$PowerBIAPI = Get-VstsInput -Name PowerBIAPI -Require

Get-VstsEndpoint $PowerBIAPI

$Api = Get-Endpoint -Name $PowerBIAPI -require
$EndpointUrl = $Api.URL

#Write-Host "PowerBIAPI::$PowerBIAPI" 
#Write-Host "Endpoint::$Api" 
#Write-Host "URL::$EndpointUrl" 

$API = Get-TaskVariableinfo 
Write-host "API ########################>"
#Write-host	$API


$Username = Get-TaskVariable -Name APIUsername -Require
$Password = Get-TaskVariable -Name APIPassword -Require
$GroupName = Get-VstsInput -Name GroupName -Require
$clientId = Get-VstsInput -Name clientId -Require
$Force = Get-VstsInput -Name Force -Require

#Write-Host "Username: $Username"
#Write-Host "Password: $Password"

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
#write-output $item	

#endregion Get Endpoint

	$resourceUrl = "https://analysis.windows.net/powerbi/api"
	$token = Get-AADToken -username $userName -Password $passWord -clientId $clientId -resource $resourceUrl -Verbose
	
write-output "Checking if group exists: $GroupName"
$Groups = Get-PBIGroup -GroupName $GroupName -AccessToken $token
Write-Output $Groups |Format-Table
$GroupID = $Groups.id

if(!([string]::IsNullOrWhiteSpace($GroupID))){

#Write-output "EndpointURL:: $($EndpointUrl)"
	$url = $EndpointUrl
    $uri =   "$($url)/myorg/groups"



## we need to check if the group contains reports before deleting
## If the Group does the we need a "Delete all reports" option

##Check if there are reports in the group
write-output "Checking for reports in group: $GroupName"
$reports = Get-PBIReports $GroupName -AccessToken $token
$reports |Format-List


	$DeleteGroup = $true

if (($reports.value).count -ne 0)
{
	Write-Host "There are reports in the Group"
	Write-Host "******************************"
	##Write-Host $reports
	if (!($Force -eq $true))
	{
		$DeleteGroup= $False
		$Status = "Aborted due to reports in the group and force not being set"
		}

	
}
if ($DeleteGroup -eq $true)
{
	Write-Output "Entering Function "
	$Status =	Remove-PBIGroup -GroupName $GroupName -AccessToken $token
	Write-Output "Returned from Function"
}
	Return $Status
#Write-output $Status
}
else
{Write-Error "Group does not exist :: $GroupName"
}