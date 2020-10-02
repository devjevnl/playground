
<#
    .SYNOPSIS
    A script to install bicep executable and the vscode extention

    .DESCRIPTION
    A slightly adapted script to install bicep executable and the its vscode extention

    .NOTES
    Author           : Jev - @devjevnl
    Version          :
                        2020-10_1 - [Jev] Initial Version
    .LINK
    https://www.devjev.nl
#>

begin {

    # Set information level to show output messages
    $InformationPreference = 'continue'
    $ErrorActionPreference = 'stop'
    # Create the install folder
    $installPath = "$env:USERPROFILE\.bicep"

}

process {
    Write-Information "Creating install directory"
    $installDir = New-Item -ItemType Directory -Path $installPath -Force
    $installDir.Attributes += 'Hidden'

    # Fetch the latest Bicep CLI binary
    Write-Information "Downloading bicep.exe"
    (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")

    # Add bicep to your PATH
    Write-Information "Setting the PATH parameter"
    $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
    if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
    if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }

    # Verify you can now access the 'bicep' command.
    bicep --help
    # Done!

    Write-Information "Downloading vscode extention"
    # Fetch the latest Bicep VSCode extension
    $vsixPath = "$env:TEMP\vscode-bicep.vsix"
    (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/vscode-bicep.vsix", $vsixPath)

    Write-Information "Installing vscode extention"
    # Install the extension
    code --install-extension $vsixPath
}

end {
    # Done!
    Write-Information "All done"
}
