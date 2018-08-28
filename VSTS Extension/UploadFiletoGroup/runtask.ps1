#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
[CmdletBinding()]
<# 
 
	Original Author:	Andrew Mitchell 
	Creation Date:		15/03/2018
	Description:		Powershell Functions to interface with the Power BI API 
						References the Import API Functions
	Pre-requisites:		DatasetOperations.psm1, GroupOperations.psm1, ReportOperations.psm1
#>
param()
Trace-VstsEnteringInvocation $MyInvocation
#Import library modules 
Import-Module  "${PSScriptRoot}\ps_modules\VstsTaskSdk\VstsTaskSdk.psm1" 
Import-Module  "${PSScriptRoot}\Powershell\Library.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\GroupOperations.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\ReportOperations.psm1" -verbose
Import-Module  "${PSScriptRoot}\Powershell\ImportOperations.psm1" -verbose

	Write-Host "Start of Main Function"
	Write-Host 


	
Write-host "Get the Parameters"
$PowerBIAPI = Get-VstsInput -Name PowerBIAPI -Require

Get-VstsEndpoint $PowerBIAPI

$Api = Get-Endpoint -Name $PowerBIAPI -require
$EndpointUrl = $Api.URL

$API = Get-TaskVariableinfo 
Write-host "API ########################>"
#Write-host	$API


$Username = Get-TaskVariable -Name APIUsername -Require
$Password = Get-TaskVariable -Name APIPassword -Require
$GroupName = Get-VstsInput -Name GroupName -Require
$PBIReports = Get-VstsInput -Name PBIReports -Require
$clientId = Get-VstsInput -Name clientId -Require
$Overwrite = Get-VstsInput -Name Overwrite -Require
$nameConflict = Get-VstsInput -Name nameConflict -Require
$PreferClientRouting = Get-VstsInput -Name PreferClientRouting -Require
$buildNumber = $env:BUILD_BUILDNUMBER

if ($PreferClientRouting -eq "false"){$PreferClientRouting = $false} else {$PreferClientRouting = $true}

Write-Host "PreferClientRouting: $PreferClientRouting"
Write-Host "nameConflict: $nameConflict"
Write-Host "buildNumber: $buildNumber"

##############################################

#region Validate Parameters
#check for a valid orgName
    if([string]::IsNullOrWhiteSpace($orgName)){$orgName = "myorg"} 
#endregion Validate Parameters



#region Get Endpoint
#Write-Host "Getting PowerBI API Name"
$APIName = Get-VstsInput -Name "PowerBIAPI"
#Write-Host $item	

#endregion Get Endpoint

	$resourceUrl = "https://analysis.windows.net/powerbi/api"
	$token = Get-AADToken -username $userName -Password $passWord -clientId $clientId -resource $resourceUrl -Verbose
	

	$authHeader = @{
					'Content-Type'='application/json'
					"Authorization" = "Bearer $($authResult)"
					}

Write-Host "Getting Groups"

$Groups = Get-PBIGroup -GroupName $GroupName -AccessToken $token

$GroupID = $Groups.id

Write-Host "Group :: $GroupName = ID :: $GroupID"


$UploadReports = Get-ChildItem $PBIReports
foreach ($Upload in $UploadReports)
{
	$directory = $Upload.directoryName
	$File = $UploadReports.Name
	$Location = "$directory\$file"
	
	$BaseFilename = [IO.Path]::GetFileNameWithoutExtension($Location)
	
	Write-Host "Upload::: $Upload"
	Write-Host "File::: $Location"

	Write-host "Check if the report exists :: $BaseFilename"

$Reports = Get-PBIReport -ReportName $BaseFilename -AccessToken $token -GroupName $GroupName
	Write-Host "::Reports found:"
	Write-Host $Reports |Format-Table
	Write-Host "::Reports found:"
	
	$OverwriteFile = $nameConflict #"Abort"

	$ReportName = $BaseFilename
# get the group ID
$GroupId = (Get-PBIGroup -GroupName $GroupName -AccessToken $token).id
	Write-Host "GroupID: $GroupID"

# Check if the report exists
$Report = (Get-PBIReport -GroupName $GroupName -ReportName $ReportName -AccessToken $token)
	Write-Host "ReportID: $($Report.ID)"

# Set Import to $true
$Import = $true

switch ($nameConflict)
{
"Abort" 
    {
		Write-host "Conflict: $nameConflict "
    }
"Overwrite" 
    {
		Write-host "Conflict: $nameConflict "
		Write-Host "Report.Name: $($Report.Name)"
		Write-Host "ReportName: $ReportName"
		Write-Host "Report.ID: $($Report.ID )"
		Write-Host "Report.ID:Null:  $([string]::IsNullOrWhiteSpace($($Report.ID )))"

	    if ($Report.Name -ne $ReportName -and ([string]::IsNullOrWhiteSpace($($Report.ID ))))
	        {
		        Write-host "Report $ReportName does not exist and Conflict: $nameConflict "
                $Import = $false
				Write-Host "Changing nameConflict to 'Abort'"
				$nameConflict ="Ignore"
				Write-host "Conflict: $nameConflict "
				$Import = $true
            }
    }
"Ignore"  
    {
		Write-host "Conflict: $nameConflict "
	    if ($Report.Name -eq $ReportName -and (!([string]::IsNullOrWhiteSpace($($Report.id )))))
	        {
		        Write-host "Report $ReportName exist and Conflict: $nameConflict"
                $Import = $false
            }
    }
}

if ($Import -eq $true)
{
## Import a power BI File
try{
	#$importGUID = Import-PowerBiFile -GroupId $GroupID -AccessToken $token -Conflict $OverwriteFile -PreferClientRouting $PreferClientRouting-Path $Location
#				
    $Status = Import-PowerBiFile -GroupId $GroupId -PreferClientRouting $PreferClientRouting  -Path $Location -AccessToken $token -Conflict $nameConflict 
}
catch
    {
    $ErrorMessage = $_.Exception.Message
    
    Write-host "Error:: $ErrorMessage"
    }
finally
{
$Publishing = Get-PBIImport -GroupName $GroupName -ImportGUID $status.id -AccessToken $token
while ($Publishing.importState -eq "Publishing") 
{
 
    $rnd = Get-Random -Minimum 1 -Maximum 5
    Write-host "Import: Running :: Sleep $rnd Seconds"
    Start-Sleep -Seconds $rnd
    $Publishing = Get-PBIImport -GroupName $GroupName -ImportGUID $status.id -AccessToken $token
    Write-host "Import: $($($publishing).importstate)"
}
}

}

}


