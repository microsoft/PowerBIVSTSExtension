#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
<# 
	Original Author: Andrew Mitchell 
	Creation Date: 15/03/2018
	Description:	Powershell Functions to interface with the Power BI API
					References the Dataset API Functions
	Pre-requisites: DatasetOperations.psm1, GroupOperations.psm1, ReportOperations.psm1
#>

Write-Host "Loading Dataset Operations Module"
Write-Host "..Load Add-PBIDataset"
function Add-PBIDataset{
<# 
	Original Author: Andrew Mitchell 
	Creation Date: 15/03/2018
	Description: 
		Powershell Functions to Add (Create) a power BI dataset using the Power BI API
	Pre-requisites: 
		DatasetOperations.psm1
		GroupOperations.psm1
			Get-PowerBiGroup
		ReportOperations.psm1
		Library.psm1
			Invoke-API 
#>
	Param(
		[parameter(Mandatory=$true)]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken,
		[Parameter(Mandatory=$true)]$Dataset,
		[Parameter(Mandatory=$false)]
		[Validateset ("None","basicFIFO")]$RetentionPolicy
	)
	<#
	Request
		POST https://api.powerbi.com/v1.0/myorg/datasets
		Enable a default retention policy
		POST https://api.powerbi.com/v1.0/myorg/datasets?defaultRetentionPolicy={None | basicFIFO}
	
	Query string parameter
		Name					Values				Description	
		defaultRetentionPolicy	None or basicFIFO	Enables a default retention policy to automatically clean up old data while keeping a constant flow of new data going into your dashboard. To learn more about automatic retention policy, see Automatic retention policy for real-time data.

	Groups
		Groups are a collection of unified Azure Active Directory groups that the user is a member of and is available in the Power BI service. These are referred to as app workspaces within the Power BI service. To learn how to create a group, see Create an app workspace.
		POST https://api.powerbi.com/v1.0/myorg/groups/{group_id}/datasets

	Uri parameter
		Name		Data Type	Description	
		group_id	String		Guid of the Group to use. You can get the group id from the Get Groups operation. Groups are referred to as app workspaces within the Power BI service.	

	Header
		Content-Type: application/json
		Authorization: Bearer eyJ0eX ... FWSXfwtQ


	#>


	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"

	if (-not [string]::IsNullOrEmpty($GroupName))
	{
		$GroupGUID=  Get-PBiGroup -GroupName $groupName -AccessToken $AccessToken
		$GroupUri = "/$GroupGUID"
	}
	else 
	{
		$GroupUri = ""
	}

	$DataSetUri = "/datasets"

	if (-not [string]::IsNullOrEmpty($RetentionPolicy))
	{
		$RetentionUri = "?defaultRetentionPolicy=$RetentionPolicy"
	}
	else
	{
		$RetentionUri = ""
	}

	$DatasetUrl = $powerbiUrl + $GroupUri + $DataSetUri + $RetentionUri



	if (-not [string]::IsNullOrEmpty($Dataset))
	{
		$Body = $Dataset
		$result =  Invoke-API -Url $DatasetUrl -Method "Get" -AccessToken $AccessToken -Verbose
		return $result
	}
	else
	{
		$result =  "No Valid dataset defined"
		Write-Error $result
		return $result
	}



  }  

Write-Host "..Load Add-PBIDatasetToGateway"
function Add-PBIDatasetToGateway{
Param(
		[parameter(Mandatory=$true)]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken,
		[Parameter(Mandatory=$true)]$Dataset,
		[Parameter(Mandatory=$true)]$GatewayID
)
<#
Request
	POST https://api.powerbi.com/v1.0/myorg/datasets/{dataset_id}/BindToGateway

Groups
	Groups are a collection of unified Azure Active Directory groups that the user is a member of and is available in the Power BI service. These are referred to as app workspaces within the Power BI service. To learn how to create a group, see Create an app workspace.
	POST https://api.powerbi.com/v1.0/myorg/groups/{group_id}/datasets/{dataset_id}/BindToGateway

Header
	Authorization: Bearer eyJ0eX ... FWSXfwtQ

Uri parameter
	Name		Data Type	Description
	group_id	String		Guid of the Group to use. You can get the group id from the Get Groups operation. Groups are referred to as app workspaces within the Power BI service.
	dataset_id	String		Guid of the dataset to use. To get a list of datasets, you can call Get Datasets.

Body schema
	{
		"gatewayObjectId": "c8aae8cf-9de8-4934-9b99-ff45302291ce",
	}

Response
	Empty

Status code
Code	Description
200		OK. Indicates success.
404		Not found
403		Unauthorized
#>

# We require the Gateway ID


}
Write-Host "Finished Loading Dataset Operations Module"