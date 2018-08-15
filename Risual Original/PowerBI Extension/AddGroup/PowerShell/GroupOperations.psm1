#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
<# 
	
  
	Original Author: Andrew Mitchell 
	Creation Date: 15/03/2018
	Description:	Powershell Functions to interface with the Power BI API 
					References the Import API Functions
	Pre-requisites: DatasetOperations.psm1, GroupOperations.psm1, ReportOperations.psm1
#>
#GroupOperations.psm1
Write-Host "Loading Group Operations Module"

Write-Host "Load Add-PBIGroup"

Function Add-PBIGroup {
<# 

  
	Original Author: Andrew Mitchell 
	Creation Date: 15/03/2018
	Description: 
		Powershell Functions to add a power BI workspace using the Power BI API
	Pre-requisites: 
		GroupOperations.psm1
			Get-PBiGroup
		Library.psm1
			Invoke-API 
#>
	Param(
		[parameter(Mandatory=$true)]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken
	)
	Write-Host "Adding Group: $GroupName"

	<#
	POST https://api.powerbi.com/v1.0/myorg/groups
	#>

	$Group = Get-PBIGroup -GroupName $GroupName -AccessToken $AccessToken

	Write-Host "Checking for Group"

	if ($Group.Name -eq $GroupName -And (!([string]::IsNullOrWhiteSpace($($Group.id ))) ))
	{
		Write-Host "Group $GroupName already exists"
	}
	else
	{
		Write-Host "Group $GroupName does not exist :: creating"
	
		$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
		$groupsUrl = $powerbiUrl + "/groups"

		Write-Host "GroupsURL:: $groupsUrl"

#		$Body = @{
#				'id'= "$GroupName"
#				'name' ="$GroupName"
#				'isReadOnly' = $false
#				}

		$Body = @{
				'name' ="$GroupName"
				}
		$json = $Body| ConvertTo-Json
		Write-Host $Json


	$response  = Invoke-API -Url $groupsUrl -Method "Post" -AccessToken $AccessToken -Body $json -ContentType "application/json" -Verbose
	return $response
	}


}


Write-Host "Load remove-PBIGroup"
Function Remove-PBIGroup{
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
		Powershell Functions to delete a power BI Workspace using the Power BI API
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
        [parameter(Mandatory=$true)]$AccessToken
	)
	Write-Host "Removing Group: $GroupName"

	<#
	The Delete group operation removes a group.
	Groups are a collection of unified Azure Active Directory groups that the user is a member of and is available in the Power BI service. These are referred to as app workspaces within the Power BI service.

Request
	DELETE https://api.powerbi.com/{version}/myorg/groups/{group_id}

Uri parameter
	Name		Data Type	Description
	group_id	String		Guid of the Group to use. You can get the group id from the Get Groups operation. Groups are referred to as app workspaces within the Power BI service.

Header
	Authorization: Bearer eyJ0eX ... FWSXfwtQ

Response
	Empty

Status code
	Code	Description
	200		Ok. Empty.
	403		Unauthorized
	404		Not found
	500		Internal service error
	#>

	$Group = Get-PBiGroup -GroupName $GroupName -AccessToken $AccessToken

	Write-Host "Checking for Group"

	if ($Group.Name -eq $GroupName -and ([string]::IsNullOrWhiteSpace($($Group.id ))))
	{
		Write-Host "Group $Groupname does not exist"
	}
	else
	{
		$groupID = $Group.ID
		Write-Host "Group $GroupName exists :: deleting"
	
		$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
		$groupsUrl = $powerbiUrl + "/groups/"+ $groupID 

		Write-Host "GroupsURL:: $groupsUrl"



	$response  = Invoke-API -Url $groupsUrl -Method "Delete" -AccessToken $AccessToken -Verbose
	return $response
	}

}

Write-Host "Load Get-PBiGroup"
Function Get-PBIGroup{
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
		Powershell Functions to check for a Workspace using the Power BI API
	Pre-requisites: 
		Library.psm1
			Invoke-API 
#>
	Param(
        [parameter(Mandatory=$true)][string]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken
    )
	Write-Host "API: Get Power BI Group"
	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
    $groupsUrl = $powerbiUrl + "/groups"
    $result = Invoke-API -Url $groupsUrl -Method "Get" -AccessToken $AccessToken -Verbose
    $groups = $result.value

    $group = $null;
    if (-not [string]::IsNullOrEmpty($groupName)){

        Write-Verbose "Trying to find group: $groupName"		
        $groups = @($groups |? name -eq $groupName)
    
        if ($groups.Count -ne 0){
            $group = $groups[0]		
        }	else 
    {

        $Group = New-Object System.Collections.ArrayList
        $item = New-Object System.Object
        $item | Add-Member -MemberType NoteProperty -Name "id" -Value $null
        $item | Add-Member -MemberType NoteProperty -Name "isReadOnly" -Value $null
        $item | Add-Member -MemberType NoteProperty -Name "isOnDedicatedCapacity" -Value $null
        $item | Add-Member -MemberType NoteProperty -Name "name" -Value "$GroupName"
        $Group.Add($item) | Out-Null
    }			
    }			

    return $group
}

Write-Host "..Load Get-PBIGroups"
Function Get-PBIGroups{
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
		Powershell Functions to get a list of Power BI workspaces using the Power BI API
	Pre-requisites: 
		Library.psm1
			Invoke-API 
#>
	Param(
        [parameter(Mandatory=$true)]$AccessToken
    )
	Write-Host "API: Get Power BI Groups"
	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
    $groupsUrl = $powerbiUrl + "/groups"
    $result = Invoke-API -Url $groupsUrl -Method "Get" -AccessToken $AccessToken -Verbose
    $groups = $result.value
    
    return $groups
}

Export-ModuleMember -Function "*" -Verbose

Write-Host "Finished Loading Group Operations Module"