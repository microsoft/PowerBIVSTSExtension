#Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT License.
# Get the Latest Powershell Modules and copy them to Master-Powershell
Write-host "Install PowerBIAPI"

$password = ConvertTo-SecureString 'aolzkthcda54giycg6da7danaymdmfd7x36xrsyf64se7bzexqba' -AsPlainText -Force
$vstsCredential = New-Object System.Management.Automation.PSCredential 'andrewm@risual.com', $password


Write-host "Getting New Package details"
if (!(Get-PackageSource -Name PowerBIAPI -ErrorAction SilentlyContinue)) {
    write-host "Package Source not registred"
    $uri = 'https://risualbidemo.pkgs.visualstudio.com/_packaging/PowerBIAPI/nuget/v2'
    register-PackageSource -Name "PowerBIAPI" -Location $uri  -ProviderName "PowerShellGet" -Credential ($vstsCredential) -Force -Trusted
}
else {
    write-host "Package Source already registred"
}



Write-host "Get installed module version"

$module = get-module -ListAvailable -refresh -name PowerBIAPI -ErrorAction SilentlyContinue
if ($module ) {

    $InstalledVersion = "$($module.Version.Major).$($module.Version.Minor).$($module.Version.Build).$($module.Version.Revision)"
    write-host "Installed Version: $InstalledVersion"

}

# Find the latest version published for release
# find the latest version of the module
$LatestVersion = (Find-Module -Name PowerBIAPI -Repository PowerBIAPI -Credential $vstsCredential)
write-host "Modules found:"
$LatestVersion |Format-List

write-host $LatestVersion.version
$InstallVersion = $LatestVersion.version #"$($LatestVersion.Version.Major).$($LatestVersion.Version.Minor).$($LatestVersion.Version.Build).$($LatestVersion.Version.Revision)"
write-host "Latest Version   : $($InstallVersion)"

if ($InstalledVersion -lt $InstallVersion -or [string]::IsNullOrEmpty($InstalledVersion) ) {
    write-host "New Module version available"
    write-host "Upgrade from: $InstalledVersion to: $InstallVersion"
    write-host "Empty: $([string]::IsNullOrEmpty($InstalledVersion))"

    if (!([string]::IsNullOrEmpty($InstalledVersion))) {
        # Remove Old Versions
        $oldversions = get-module -Name powerbiapi -ListAvailable 
        foreach ($oldversion in $oldversions) {
            uninstall-module -Name PowerBIAPI -RequiredVersion $oldversion.version -verbose

        }
        else 
        {
            Write-Host "No old Versions to remove"
        }
    }
    
    # Install the latest version
    # Use force to allow for replacement of existing module

    Write-host "Installing the module"
    Install-module -Name PowerBIAPI -Repository PowerBIAPI -Credential $vstsCredential -Scope CurrentUser -MinimumVersion $($InstallVersion) -force -Verbose

    # Install the latest Version


    $defaultPath = ($env:PSModulePath.split(";"))[0]
        
    $modulePath = "$defaultPath\PowerBIAPI\$InstallVersion"
    Write-Host "Path: $ModulePath"

    # import the module
    import-module -Name $modulePath\PowerBIAPI -Verbose
}
