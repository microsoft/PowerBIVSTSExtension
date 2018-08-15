#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
$uri = "https://api.powerbi.com/v1.0/" + $orgName + "/groups/" + $groupName + "/imports"
$response = Invoke-RestMethod -Uri $uri -Method Post -Infile $filepath -ContentType 'multipart/form-data'