#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
<# 
	IMPORTANT LEGAL NOTICE: PLEASE BE AWARE THAT THIS CODE AND/OR SCRIPT 
	(SOFTWARE) IS THE EXCLUSIVE PROPERTY OF RISUAL LIMITED AND IS PROTECTED. 
	IT IS A CRIMINAL OFFENCE TO COPY OR RE-PRODUCE IN WHOLE OR PART ANY ELEMENT 
	OF THIS SOFTWARE. 
 
	Copyright © 2018 risual Ltd. 
	Full Terms and Conditions http://www.risual.com/Pages/Terms-of-Business.aspx 
	All Rights Reserved. 
 
	Company Confidential 
  
	Original Author: Andrew Mitchell 
	Creation Date: 15/03/2018
	Description:	Powershell Functions to interface with the Power BI API 
					References the Import API Functions
	Pre-requisites: DatasetOperations.psm1, GroupOperations.psm1, ReportOperations.psm1
#>
Write-Host "Loading Group Operations Module"

Write-Host "..Load Get-PBIReports"
Function Get-PBIReports {
<# 
	IMPORTANT LEGAL NOTICE: PLEASE BE AWARE THAT THIS CODE AND/OR SCRIPT 
	(SOFTWARE) IS THE EXCLUSIVE PROPERTY OF RISUAL LIMITED AND IS PROTECTED. 
	IT IS A CRIMINAL OFFENCE TO COPY OR RE-PRODUCE IN WHOLE OR PART ANY ELEMENT 
	OF THIS SOFTWARE. 
 
	Copyright © 2018 risual Ltd. 
	Full Terms and Conditions http://www.risual.com/Pages/Terms-of-Business.aspx 
	All Rights Reserved. 
 
	Company Confidential 
  
	Original Author: Andrew Mitchell 
	Creation Date: 15/03/2018
	Description: 
		Powershell Functions to get a list of power BI reports in a group using the Power BI API
	Pre-requisites: 
		Library.psm1
			Invoke-API 
#>
	Param(
		[parameter(Mandatory=$true)]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken
	)
	Write-Output "Getting a list of reports Contained in  Group: $GroupName"

<###################################################################
The Get Reports operation returns a JSON list of all Report objects which includes an id, name, webUrl, and embedUrl, or a JSON list of reports from an App workspace (group).

Request
	GET https://api.powerbi.com/v1.0/myorg/reports
Groups
	Groups are a collection of unified Azure Active Directory groups that the user is a member of and is available in the Power BI service. These are referred to as app workspaces within the Power BI service. To learn how to create a group, see Create an app workspace.
	GET https://api.powerbi.com/v1.0/myorg/groups/{group_id}/reports

Uri parameter
	Name		Data Type	Description
	group_id	String		Guid of the Group to use. You can get the group id from the Get Groups operation. Groups are referred to as app workspaces within the Power BI service.

Header
	Authorization: Bearer eyJ0eX ... FWSXfwtQ
Response


Status code
	Code	Description
	200		OK. Indicates success. List of reports.
	403		Unauthorized
	404		Not found
	500		Internal service error

Content-Type
	application/json
Body schema
	Reports have a GUID id, name, webUrl, and embedUrl. You use the embedUrl to embed a report in an app.


	{
	 "odata.context": "string",
	"value": [
	 {
	   "id": "string",
		  "name": "string",
		 "webUrl": "string",
		 "embedUrl": "string",
		"datasetId": "string"
	 }
	]
	}

####################################################################>


	## First we need the group ID
	$Groups = Get-PBIGroup -GroupName $GroupName -AccessToken $AccessToken
	Write-Output $Groups |Format-Table
	$GroupID = $Groups.id

	Write-Output "Using GroupID:: $GroupID"

	## then we need to find out if there are reports in the Group
	## we do this by calling the API with the group ID

	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
	$reportsUrl = $powerbiUrl + "/groups/"+ $GroupID  + "/reports"

	Write-Host $reportsUrl

	$response  = Invoke-API -Url $reportsUrl -Method "Get" -AccessToken $AccessToken -Verbose
	

	## then we return the list of reports
	return $response

}

Write-Host "Load Get-PowerBiReport"
Function Get-PBIReport{
    Param(
        [parameter(Mandatory=$true)][string]$GroupName,
		[parameter(Mandatory=$true)][string]$ReportName,
        [parameter(Mandatory=$true)]$AccessToken
    )
	
    $groupId = Get-PBIGroup -GroupName $GroupName -AccessToken $AccessToken 
	$groupId = $groupId.id

	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
	$groupsUrl = $powerbiUrl + "/groups"
	$reportsUrl = $groupsUrl + "/" + $groupId +"/reports"

    $result = Invoke-API -Url $reportsUrl -Method "Get" -AccessToken $AccessToken -Verbose
    $Reports = $result.value

    $group = $null;
    if (-not [string]::IsNullOrEmpty($ReportName)){

        Write-Verbose "Trying to find report: $ReportName"		
        $Reports = @($Reports |? name -eq $ReportName)
    
        if ($Reports.Count -ne 0){
            $Report = $Reports[0]		
        }				
    }

    return $Report}

Write-Host "Finished Loading Report Operations Module"