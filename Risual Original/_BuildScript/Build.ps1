#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
###########################################

# For Andy's Build
# cd to the folder where the VSTS Plugin resides
cd "$ENV:Homepath\source\Microsoft\msdavelusty.visualstudio.com"

###########################################
# For Dave's Build
# cd to the folder where the VSTS Plugin resides
#cd 'C:\%Homepath%\source\Microsoft\msdavelusty.visualstudio.com'


# Access token for Marketplace Publishing
# see https://docs.microsoft.com/en-us/vsts/extend/publish/command-line?view=vsts

# This is currently Andy's token so will need to be changed for publishing
$Token = "whu5x7gpnrydccdrpv3kgblonkkqth52fx477es7kfxivsd4ccwa" 


# Archive all of the existing built extensions
Move *.vsix .\Archive -Force

# Copy all items from the Master Powershell folder to the Task folders
copy .\Master-Powershell\*.psm1 .\DeleteReport\PowerShell
copy .\Master-Powershell\*.psm1 .\UploadFiletoGroup\PowerShell
copy .\Master-Powershell\*.psm1 .\AddGroup\PowerShell
copy .\Master-Powershell\*.psm1 .\DeleteGroup\PowerShell
copy .\Master-Powershell\*.psm1 .\sample\PowerShell

# C:\Users\andrewm\AppData\Roaming\npm\tfx extension create --manifest-globs vss-extension.json 
# C:\Users\andrewm\AppData\Roaming\npm\tfx extension publish --help



C:\users\andrewm\AppData\Roaming\npm\tfx extension publish --rev-version --manifest-globs PowerBIExtension.json  --token $Token
C:\%Homepath%\AppData\Roaming\npm\tfx extension publish  --manifest-globs vss-extension.json  --token $Token --share-with risualbidemo

git
