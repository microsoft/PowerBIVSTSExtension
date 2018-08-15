#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
<# 

  
	Original Author: Andrew Mitchell 
	Creation Date: 15/03/2018
	Description:	Powershell Functions to interface with the Power BI API 
					References the Import API Functions
	Pre-requisites: DatasetOperations.psm1, GroupOperations.psm1, ReportOperations.psm1
#>
#ImportOperations.psm1
Write-Host "Loading Import Operations Module"

Write-Host "..Load Import-PowerBIReport"
function Import-PowerBIReport{
<# 

  
	Original Author: Andrew Mitchell 
	Creation Date: 15/03/2018
	Description: 
		Powershell Functions to import a power BI Report using the Power BI API
	Pre-requisites: 
		DatasetOperations.psm1
		GroupOperations.psm1
			Get-PBiGroup
		ReportOperations.psm1
		Library.psm1
			Invoke-API 
#>
    Param(
        [parameter(Mandatory=$true)][string]$GroupName,
		[parameter(Mandatory=$true)][string]$ReportName,
        [parameter(Mandatory=$true)]$AccessToken,
		[Parameter(Mandatory=$true)]$Inifile,
		[Parameter(Mandatory=$true)]$datasetDisplayName,
		[Parameter(Mandatory=$true)]$nameConflict,
		[Parameter(Mandatory=$true)]$PreferClientRouting
    )

    $groupId = Get-PBiGroup -GroupName $GroupName -AccessToken $AccessToken 
	$groupId = $groupId.id

	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
	$groupsUrl = $powerbiUrl + "/groups"
	$UploadURL = $groupsUrl + "/" + $groupId  + "/imports?datasetDisplayName=" + $datasetDisplayName +"&nameConflict=" + $nameConflict + "&PreferClientRouting=" + $PreferClientRouting
	Write-Host $UploadURL
	$uri = "https://api.powerbi.com/v1.0/" + $orgName + "/groups/me/imports?datasetDisplayName=" + $datasetDisplayName +"&nameConflict=" + $nameConflict + "&PreferClientRouting=" + $PreferClientRouting 




$powerBiBodyTemplate = @'

--{0}

Content-Disposition: form-data; name="fileData"; filename="{1}"

Content-Type: application/x-zip-compressed



{2}

--{0}--



'@


	$fileName = [IO.Path]::GetFileName($Inifile)
	$boundary = [guid]::NewGuid().ToString()
	$fileBytes = [System.IO.File]::ReadAllBytes($Inifile)
	$encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
	$url = "$powerbiUrl/groups/$GroupId/imports?datasetDisplayName=$fileName&nameConflict=$nameConflict"
	$filebody = $encoding.GetString($fileBytes)



    $body = $powerBiBodyTemplate -f $boundary, $fileName, $encoding.GetString($fileBytes)

    $Body = @{
	    	'filePath'= $Inifile
	    	'connectionType'= 'import'
	    	}
	#write-host $Body
	$result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "multipart/form-data; boundary=--$boundary" 
##$result = Invoke-API -Url $UploadURL -Method "Post" -Body $Body -AccessToken $AccessToken -ContentType 'multipart/form-data'
return $result
}

Write-Host "..Load Import-PowerBiFile"
Function Import-PowerBiFile{
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
	Description: Powershell Functions import a file using the Power BI API
	Pre-requisites: 
		DatasetOperations.psm1
		GroupOperations.psm1
			Get-PBiGroup
		ReportOperations.psm1
		Library.psm1
			Invoke-API 
#>
    Param(
        [parameter(Mandatory=$true)]$GroupId,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$Conflict,
		[parameter(Mandatory=$true)]$PreferClientRouting,
        [parameter(Mandatory=$true)]$Path
    )
    $powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
    $resourceUrl = "https://analysis.windows.net/powerbi/api"

$powerBiBodyTemplate = @'
--{0}
Content-Disposition: form-data; name="fileData"; filename="{1}"
Content-Type: application/x-zip-compressed

{2}
--{0}--

'@

	$fileName = [IO.Path]::GetFileName($Path)
	$boundary = [guid]::NewGuid().ToString()
	$fileBytes = [System.IO.File]::ReadAllBytes($Path)
	$encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")

	$BaseFilename = [IO.Path]::GetFileNameWithoutExtension($fileName)

	Write-Host "Filename $fileName"
	$url = "$powerbiUrl/groups/$GroupId/imports?datasetDisplayName=$BaseFilename&nameConflict=$Conflict&PreferClientRouting=$PreferClientRouting"
	$filebody = $encoding.GetString($fileBytes)
	Write-Host "URL $url"
    $body = $powerBiBodyTemplate -f $boundary, $filebody, $encoding.GetString($fileBytes)
    $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "multipart/form-data; boundary=--$boundary"  
    return $result
}

Write-Host "..Load Get-PBIImport"
function Get-PBIImport{
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
	Description: Powershell Functions to check the status of a running import using the Power BI API
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
        [parameter(Mandatory=$true)]$ImportGUID
		)
	
	$GroupID = (Get-PBiGroup -GroupName $GroupName -AccessToken $AccessToken).id
	
	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"

    $ImportUrl = $powerbiUrl + "/groups/$GroupID/imports/$ImportGUID"
	#$ImportUrl = $powerbiUrl + "/imports/$ImportGUID"
	$result = Invoke-API -Url $ImportUrl -Method "Get" -AccessToken $AccessToken -Verbose
    return $result
}


Write-Host "Finished Loading Import Operations Module"