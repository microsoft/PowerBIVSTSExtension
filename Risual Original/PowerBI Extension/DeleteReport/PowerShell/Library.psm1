#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
Write-Host "######> Library Module"




Write-Host "Load Get-GroupPS"
function Get-GroupsPS
(
    [Parameter(Mandatory=$true)]
    [system.collections.hashtable] $Header,
    [Parameter(Mandatory=$false)]
    [string] $GroupName
)
{
  
    $uri = "https://api.powerbi.com/v1.0/myorg/groups"
    $response = Invoke-RestMethod -Uri $uri -Method get -Headers $Header  -verbose 
    $Grouplist = $response.value

    # check for retirned value
    if ($Grouplist.Count -ne 0)
    {
        # Values returned
        # test for the value wanted
        # Test if the wanted value is null
        if ([string]::IsNullOrWhiteSpace($GroupName))
        {
        # no value specified
            Write-host "Group: No Group Specified"
            return $response.value
        }
        else
        {
        Write-host "Group: $GroupName"
        #m getting group name
            $Grouplist = @($Grouplist |? name -eq $GroupName)

                   if ($Grouplist.Count -ne 0)
                   {
                   write-host "Filtered Group"
                    $group=$Grouplist[0]
                    }
        }
    }
    else 
    {
        #No values returned
    Write-host "Group: None Returned"
        return $response.value
    }
 return $Group
}

Write-Host "Load Get-AADToken"
Function Get-AADToken{

    Param(

        [parameter(Mandatory=$true)][string]$Username,

        [parameter(Mandatory=$true)][string]$Password,

        [parameter(Mandatory=$true)][guid]$ClientId,

        [parameter(Mandatory=$true)][string]$Resource

    )



    $authorityUrl = "https://login.microsoftonline.com/common/oauth2/authorize"



    ## load active directory client dll

    $typePath = $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

    Add-Type -Path $typePath 



    Write-Verbose "Loaded the Microsoft.IdentityModel.Clients.ActiveDirectory.dll"



    Write-Verbose "Using authority: $authorityUrl"

    $authContext = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext -ArgumentList ($authorityUrl)

    $credential = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential -ArgumentList ($userName, $passWord)

    

    Write-Verbose "Trying to aquire token for resource: $resource"

    $authResult = $authContext.AcquireToken($resource,$clientId, $credential)



    Write-Verbose "Authentication Result retrieved for: $($authResult.UserInfo.GivenName)"

    return $authResult.AccessToken

}

Write-Host "Load GetAuthToken0"
function GetAuthToken0
{
  param
  (
    [Parameter(Mandatory=$true)]
    [string]$TenantName,
    [Parameter(Mandatory=$true)]
    [string]$clientId,
    [Parameter(Mandatory=$true)]
    [string]$User,
    [Parameter(Mandatory=$true)]
    [string]$Password
  )
    write-host ".."
	write-host "Begining GetAuthToken" -ForegroundColor Gray
#region Print Parameters
    Write-host "  "
    Write-Host "Parameters" -ForegroundColor Yellow
    Write-Host "TenantName : $TenantName"
    Write-Host "clientId : $clientId"
	Write-Host "User : $User"
	Write-Host "Password : $Password"
    write-host "  "

#endregion Print Parameters

    Write-host "Loading Components" -ForegroundColor Yellow
    # Load Active Directory Dll 
    #$adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adal = $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

    #$adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
    $adalforms  = $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
       
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
    Write-host "Loaded Microsoft.IdentityModel.Clients.ActiveDirectory.dll" 
    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
    Write-host "Loaded Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll" 

    $redirectUri = "https://login.live.com/oauth20_desktop.srf"#"urn:ietf:wg:oauth:2.0:oob"
    $resourceAppIdURI = "https://analysis.windows.net/powerbi/api"#"https://graph.windows.net"
    $authority = "https://login.microsoftonline.com/common/oauth2/authorize" #"https://login.windows.net/$TenantName"

    $creds = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential" -ArgumentList $User,$password
   
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

    write-host "Acquiring Token ($authority)" 
    #$authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId,$creds)
    $authResult = $authContext.AcquireToken($resourceAppIdURI,$clientId, $creds)
	
    write-host " "
	$authContext
    write-host "Ending GetAuthToken" 
    write-host " "
	write-host ".."
    return $authResult
}

Write-Host "Load GetAuthToken"
function GetAuthToken
{
(
    [Parameter(Mandatory=$true)]
    [string]$TenantName,
    [Parameter(Mandatory=$true)]
    [string]$clientId,
    [Parameter(Mandatory=$true)]
    [string]$User,
    [Parameter(Mandatory=$true)]
    [string]$Password
)

	Add-Type -Path $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
	Add-Type -Path $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll" 

#	$adal = $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
#	$adal
#   $adalforms  = $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
#	$adalforms

	Write-host "Load ActiveDirectory"
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
    Write-host "Loaded Microsoft.IdentityModel.Clients.ActiveDirectory.dll" 
Write-host "Load Winforms"
    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
    Write-host "Loaded Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll" 




#    $username = "Andoius@sky.com"
#    $password = "49Saber10!"
#    $TenantName = "398a6ed0-01ba-4c7b-9c28-2b6f95c50232"
#    $clientId = "1fe165cd-a395-4fde-ab05-81b073ec773b"

    $redirectUri = "https://login.live.com/oauth20_desktop.srf" #"urn:ietf:wg:oauth:2.0:oob"
    $resourceAppIdURI = "https://analysis.windows.net/powerbi/api"
    $authority = "https://login.microsoftonline.com/common/oauth2/authorize" 


	$resourceUrl = "https://analysis.windows.net/powerbi/api"
	Write-Host "Authenticating with : $authority"
	$authContext = New-Object -TypeName  "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
	Write-Host "Creating Credentials"
	$creds = New-Object -TypeName  "Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential" -ArgumentList $username,$password -Verbose

	$authResult = $authContext.AcquireToken($resourceAppIdURI,$clientId, $creds)
	Write-Host  "$($authResult.UserInfo.GivenName) Has Authenticated"
	return $authResult.AccessToken
}

Write-Host "Load GetAuthToken2"
function GetAuthToken2
{
(
    [Parameter(Mandatory=$true)]
    [string]$TenantName,
    [Parameter(Mandatory=$true)]
    [string]$clientId,
    [Parameter(Mandatory=$true)]
    [string]$User,
    [Parameter(Mandatory=$true)]
    [string]$Password
)
	$appid ="1fe165cd-a395-4fde-ab05-81b073ec773b"
	$objID ="36cb94ee-cb29-46e2-a5f9-a0abc5a0e3b4"
	$clientId = "1fe165cd-a395-4fde-ab05-81b073ec773b"
	$User = "andoius@sky.com"
	$Password ="49Saber10!"
    $adal = $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adalforms  = $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"

Write-host "Load ActiveDirectory"
    [System.Reflection.Assembly]::LoadFrom($adal) #| Out-Null
    Write-host "Loaded Microsoft.IdentityModel.Clients.ActiveDirectory.dll" 
Write-host "Load Winforms"
    [System.Reflection.Assembly]::LoadFrom($adalforms) #| Out-Null
    Write-host "Loaded Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll" 


    $redirectUri = "https://login.live.com/oauth20_desktop.srf"#"urn:ietf:wg:oauth:2.0:oob"
    $resourceAppIdURI = "https://analysis.windows.net/powerbi/api"#"https://graph.windows.net"
    $authority = "https://login.microsoftonline.com/common/oauth2/authorize" #"https://login.windows.net/$TenantName"

	$creds = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential" -ArgumentList $User,$password
	$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
	write-host "resourceAppIdURI $resourceAppIdURI"
		Write-Host "clientId $clientId"
	Write-Host "creds $creds"
	$authResult = $authContext.AcquireToken($resourceAppIdURI,$clientId, $creds)
	return $authResult
}

# Get Reports
Write-Host "Load Get-Reports"
Function Get-Reports(
    [Parameter(Mandatory=$true)]
    [system.collections.hashtable]$Header,
    [Parameter(Mandatory=$true)]
    [string]$GroupID,
    [Parameter(Mandatory=$false)]
    [string]$URI
)
{
    write-output "Getting reports"
	write-output "URI::$($uri)"
	Write-Output "Header:: $($Header)"

   # $uri = "https://api.powerbi.com/v1.0/myorg/groups/$GroupID/reports"
	Invoke-RestMethod -Uri $uri -Method get -Headers $Header  -verbose 
    $response = Invoke-RestMethod -Uri $uri -Method get -Headers $Header  -verbose 
    return $response.value
}

Write-Host "Load Add-Group"
function Add-Group
(    [Parameter(Mandatory=$true)]$Token,
    [Parameter(Mandatory=$true)]
    [string]$GroupName)
{ write-output "Getting Groups"
    $uri = "https://api.powerbi.com/v1.0/myorg/groups"
    $response = Invoke-RestMethod -Uri $uri -Method post -Headers $Header  }

Write-Host "Load Get-Groups2"
	function Get-Groups2(
    [Parameter(Mandatory=$true)]
    [system.collections.hashtable]$Header,
    [Parameter(Mandatory=$false)]
    [string]$Group
)
{
    
    $uri = "https://api.powerbi.com/v1.0/myorg/groups"
	Invoke-RestMethod -Uri $uri -Method get -Headers $Header  -verbose 
    $response = Invoke-RestMethod -Uri $uri -Method get -Headers $Header  -verbose 
    # check for retirned value
    if ($response.value.Count -ne 0)
    {
        # Values returned
        # test for the value wanted
        # Test if the wanted value is null
        if ([string]::IsNullOrWhiteSpace($Group))
        {
        # no value specified
            return $response.value
        }
        else
        {
            $result = @($response |? name -eq $Group)
                   if ($result.Count -eq 0)
                   {
                    return $response.value 
                    }
        }
    }
    else 
    {
        #No values returned
        return $response.value
    }
 
}



# get groups
Write-Host "Load Get-Groups"
function Get-Groups(
    [Parameter(Mandatory=$true)]
    $Token,
    [Parameter(Mandatory=$false)]
    [string]$Group
)
{

	$Uri = "https://api.powerbi.com/v1.0/myorg"
	$groupsUri = $Uri + "/groups"
	$Header = @{
		'Content-Type'='application/json'
		 'Authorization'= "Bearer $Token"
    }

Write-Host "Group: $Group"
Write-Host "Token: $Token"
Write-Host "groupsUri: $groupsUri"	
Write-Host "Header: $Header"	




	$Wr = Invoke-RestMethod -Method "Get" -Uri $groupsUri  -Headers $Header 
	$Wr.value
	return $Wr.value
}
##########################


#Write-Host "Load Get-PowerBiGroup"
#Function Get-PowerBiGroup{
#    Param(
#        [parameter(Mandatory=$true)][string]$GroupName,
#        [parameter(Mandatory=$true)]$AccessToken
#    )
#	Write-Output "API: Get Power BI Group"
#	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
#    $groupsUrl = $powerbiUrl + "/groups"
#    $result = Invoke-API -Url $groupsUrl -Method "Get" -AccessToken $AccessToken -Verbose
#    $groups = $result.value

#    $group = $null;
#    if (-not [string]::IsNullOrEmpty($groupName)){

#        Write-Verbose "Trying to find group: $groupName"		
#        $groups = @($groups |? name -eq $groupName)
    
#        if ($groups.Count -ne 0){
#            $group = $groups[0]		
#        }				
#    }

#    return $group
#}
######################################
Write-Host "Load Invoke-API"
Function Invoke-API{
    Param(
        [parameter(Mandatory=$true)][string]$Url,
        [parameter(Mandatory=$true)][string]$Method,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$false)][string]$Body,
        [parameter(Mandatory=$false)][string]$ContentType
    )

    $apiHeaders = @{
		'Content-Type'='application/json'
	    'Authorization'= "Bearer $AccessToken"
    }

	Write-Verbose "Trying to invoke api: $Url"

    if($Body){
        $result = Invoke-RestMethod -Uri $Url -Headers $apiHeaders -Method $Method -ContentType $ContentType -Body $Body
    }else{
        $result = Invoke-RestMethod -Uri $Url -Headers $apiHeaders -Method $Method
    }

    return $result
}

Write-Host "Load Delete-Report"
function Delete-Report{
	    Param(
        [parameter(Mandatory=$true)]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$ReportName
		)


<#
Delete report
 
API Version: July 21, 2017


DELETE https://api.powerbi.com/v1.0/myorg/reports/{report_id}
Groups
	Groups are a collection of unified Azure Active Directory groups that the user is a member of and is available in the Power BI service. These are referred to as app workspaces within the Power BI service. To learn how to create a group, see Create an app workspace.
	DELETE https://api.powerbi.com/v1.0/myorg/groups/{group_id}/reports/{report_id}
Uri parameter
	Name		Data Type	Description						
	group_id	String		Guid of the Group to use. You can get the group id from the Get Groups operation. Groups are referred to as app workspaces within the Power BI service.
	report_id	String		Guid of the report to get. You can get the report id from the Get reports operation.

Header
	Authorization: Bearer eyJ0eX ... FWSXfwtQ

Response

Empty response

Status code		
	Code	Description
	200		OK. Indicates success.
	404		Not found
	403		Unauthorized
	500		Internal service error

#>

#Check if Group exists
$GroupID = Get-PowerBiGroup -GroupName $GroupName -AccessToken $AccessToken
if (-not [string]::IsNullOrEmpty($GroupID)){
	#Group Exists so we can check for the report

	Write-Information "Group: $GroupName Found in power BI"
# check if the report exists
	$ReportID = Get-PowerBiReport -GroupName $GroupName -ReportName $ReportName -AccessToken $AccessToken
	if (-not [string]::IsNullOrEmpty($ReportID)){
		#Report Exists so we can delete it
		Write-Information "Report: $ReportName Found in Group: $GroupName"
		}
	else
	{
		Write-Error "Report: $ReportName Does not exist in Group: $GroupName"
	}
$reportStatus = Get-PowerBiReport -GroupName $GroupName

}
else
{
	Write-Error "Group: $GroupName Does not exist in Power BI"
}
	}



Write-Host "Load Update-TableSchema"
Function Update-TableSchema{
	Param(
        [parameter(Mandatory=$true)]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken,
		[Parameter(Mandatory=$true)]$DatasetName
	)
	<#
	Request
	PUT https://api.powerbi.com/v1.0/myorg/datasets/{dataset_id}/tables/{table_name}

	#>




}



Write-Host "Load Create-Dataset"
Function Create-Dataset{
	Param(
        [parameter(Mandatory=$true)]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken,
		[Parameter(Mandatory=$true)]$DatasetName,
		[Parameter(Mandatory=$true)]$RetentionPolicy
	)
}



Write-Host "######> Library Module"