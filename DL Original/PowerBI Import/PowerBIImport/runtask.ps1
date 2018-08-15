#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $orgName,
    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $filepath,
    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $datasetDisplayName,
    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $nameConflict,
    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $PreferClientRouting,
    [string]$replaceRegex,
    [string]$buildNumber = $env:BUILD_BUILDNUMBER
)

$uri = "https://api.powerbi.com/v1.0/" + $orgName + "/imports?datasetDisplayName=" + $datasetDisplayName +"nameConflict=" + $nameConflict + "PreferClientRouting=" + $PreferClientRouting

$response = Invoke-RestMethod -Uri $uri -Method Post -Infile $filepath -ContentType 'multipart/form-data'

