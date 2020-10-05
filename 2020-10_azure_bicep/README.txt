
ON VM ----------------------------------------------------------------------------------------
- Create new regular user on VM
- Set user role as administrator (add Local admin group membership)
- Logon to the VM with the new user
----------------------------------------------------------------------------------------------


PowerShell 5 - Administrator Mode ------------------------------------------------------------
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
----------------------------------------------------------------------------------------------


PowerShell 7: Basic Install ------------------------------------------------------------------
cd c:\dev\

$installFeatures = @("Git", "VSCode", "VSPwsh", "AzModule")
.\Install-DevFeatures.ps1 -InstallFeatures $installFeatures

$installFeatures = @("Bicep", "VSBicep")
.\Install-DevFeatures.ps1 -InstallFeatures $installFeatures

TEST bicep: In VS Code run: bicep --help
----------------------------------------------------------------------------------------------


DEMO Links: ----------------------------------------------------------------------------------
https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/2019-06-01/storageaccounts
----------------------------------------------------------------------------------------------





Link to Installation manual:
https://github.com/Azure/bicep/blob/master/docs/installing.md

Link to guides:
https://github.com/Azure/bicep/tree/master/docs/tutorial

Link to Bicep Language Specification:
https://github.com/Azure/bicep/blob/master/docs/spec/bicep.md
