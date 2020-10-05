<#
    .SYNOPSIS
    A script to install all required products for Bicep demo

    .DESCRIPTION
    A script to install all required products for Bicep demo

    .PARAMETER InstallFeatures
    An array of strings representing the features to install, currently supported values:
    Git, Bicep, VSCode, VSPwsh, VSBicep, AzModule

    .NOTES
    Author           : Jev - @devjevnl
    Version          :
                        2020-10_1 - [Jev] Initial Version
    .LINK
    https://www.devjev.nl
#>

[CmdLetBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [System.String[]] $InstallFeatures
)

begin {
    $repoRoot = $PSScriptRoot

    # Set information level to show output messages
    $InformationPreference = 'continue'
    $ErrorActionPreference = 'stop'

    $installPath = "$env:USERPROFILE\.bicep"

    Write-Information "Creating Bicep install directory"
    $installDir = New-Item -ItemType Directory -Path $installPath -Force
    $installDir.Attributes += 'Hidden'

    $codeCmdPath = "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"
}

process {

    if ($InstallFeatures.Contains("Git")) {
        # Fetch the latest Git executable
        Write-Information "`nDownloading Git"
        $gitVersions = (Invoke-RestMethod "https://api.github.com/repos/git-for-windows/git/releases/latest").assets
        $desiredVersion = $gitVersions | Where-Object { $_.name -like "*64-bit.exe" }

        $gitPath = "$env:TEMP\Git-64-bit.exe"
        (New-Object Net.WebClient).DownloadFile($($desiredVersion.browser_download_url), $gitPath)

        # install gIT
        Write-Information "Installing Git`n"
        Start-Process -Wait $gitPath -ArgumentList /VERYSILENT, /NORESTART, /NOCANCEL, /LOADINF="$repoRoot\git.inf"
    }

    if ($InstallFeatures.Contains("Bicep")) {
        # Fetch the latest Bicep CLI binary
        Write-Information "Downloading bicep.exe"
        (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")

        # Add bicep to your PATH
        Write-Information "Installing Bicep`n"
        $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
        if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
        if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
    }

    if ($InstallFeatures.Contains("VSCode")) {
        # Fetch the latest VSCode
        Write-Information "Downloading VSCode"
        $vsCodePath = "$env:TEMP\vscode.exe"
        (New-Object Net.WebClient).DownloadFile("https://aka.ms/win32-x64-user-stable", $vsCodePath)

        Write-Information "Installing VSCode`n"
        Start-Process -Wait $vsCodePath -ArgumentList /silent, /mergetasks=!runcode
    }

    if ($InstallFeatures.Contains("VSPwsh")) {
        # Installing extension extentions
        Write-Information "Installing vscode PowerShell extention"
        & $codeCmdPath --install-extension  ms-vscode.powershell
    }

    if ($InstallFeatures.Contains("VSBicep")) {
        # Fetch the latest Bicep VSCode extension
        Write-Information "Downloading Bicep VSCode extention"
        $vsixPath = "$env:TEMP\vscode-bicep.vsix"
        (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/vscode-bicep.vsix", $vsixPath)

        Write-Information "Installing vscode Bicep extentionn`n"
        & $codeCmdPath --install-extension $vsixPath
    }

    if ($InstallFeatures.Contains("AzModule")) {
        # install PowerShell AZ module
        Write-Information "Installing AZ Module, be patient this will take a while!`n"
        Install-Module -Name Az -Repository PSGallery -Force -Verbose
    }
}

end {
    # Clean up files
    Write-Information "Removing downloaded files..."
    if ($InstallFeatures.Contains("VSBicep")) {
        Remove-Item $vsixPath
    }

    if ($InstallFeatures.Contains("VSCode")) {
        Remove-Item $vsCodePath
    }
    Write-Information "All Done!!!"
}
