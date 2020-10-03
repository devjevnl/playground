<#
    .SYNOPSIS
    A script to install all required products for Bicep demo

    .DESCRIPTION
    A script to install all required products for Bicep demo

    .NOTES
    Author           : Jev - @devjevnl
    Version          :
                        2020-10_1 - [Jev] Initial Version
    .LINK
    https://www.devjev.nl
#>

function Install-vmFeatures {
    [CmdLetBinding()]
    param(
        [Parameter()]
        [switch] $SkipVSCode,

        [Parameter()]
        [switch] $SkipPwshExtention,

        [Parameter()]
        [switch] $SkipAzModule,

        [Parameter()]
        [switch] $SkipGit
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

        # Fetch the latest Bicep CLI binary
        Write-Information "Downloading bicep.exe"
        (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")

        # Fetch the latest VSCode
        Write-Information "Downloading VSCode"
        $vsCodePath = "$env:TEMP\vscode.exe"
        (New-Object Net.WebClient).DownloadFile("https://aka.ms/win32-x64-user-stable", $vsCodePath)

        # Fetch the latest Bicep VSCode extension
        Write-Information "Downloading Bicep VSCode extention"
        $vsixPath = "$env:TEMP\vscode-bicep.vsix"
        (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/vscode-bicep.vsix", $vsixPath)

        $gitVersions = (Invoke-RestMethod "https://api.github.com/repos/git-for-windows/git/releases/latest").assets
        $desiredVersion = $gitVersions | Where-Object { $_.name -like "*64-bit.exe" }  

        # Fetch the latest Bicep CLI binary
        Write-Information "Downloading Git.exe"
        $gitPath = "$env:TEMP\Git-64-bit.exe"
        (New-Object Net.WebClient).DownloadFile($($desiredVersion.browser_download_url), $gitPath)

        $codeCmdPath = "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"
    }

    process {

        # Add bicep to your PATH
        Write-Information "Setting Bicep PATH parameter"
        $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
        if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
        if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }

        if ($SkipVSCode.IsPresent -eq $false) {
            Write-Information "Installing VSCode"
            Start-Process -Wait $vsCodePath -ArgumentList /silent, /mergetasks=!runcode
        } else {
            Write-Information "SKIPPING: Installing VSCode"
        }

        if ($SkipPwshExtention.IsPresent -eq $false) {
            # Installing extension extentions
            Write-Information "Installing vscode PowerShell extention"
            & $codeCmdPath --install-extension  ms-vscode.powershell
        } else {
            Write-Information "SKIPPING: Installing vscode PowerShell extention"
        }

        Write-Information "Installing vscode Bicep extention"
        & $codeCmdPath --install-extension $vsixPath

        if ($SkipAzModule.IsPresent -eq $false) {
            # install PowerShell AZ module
            Write-Information "Installing AZ Module"
            Install-Module -Name Az -Repository PSGallery -Force -Verbose
        } else {
            Write-Information "SKIPPING: Installing AZ Module"
        }

        if ($SkipGit.IsPresent -eq $false) {
            # install gIT
            Write-Information "Installing Git"
            Start-Process -Wait $gitPath -ArgumentList /VERYSILENT, /NORESTART, /NOCANCEL, /LOADINF="$repoRoot\git.inf"
        } else {
            Write-Information "SKIPPING: Installing Git"
        }
    }

    end {
        # Clean up files
        Write-Information "Removing downloaded files..."
        Remove-Item $vsixPath
        Remove-Item $vsCodePath

        Write-Information "All Done!!!"
    }
}
