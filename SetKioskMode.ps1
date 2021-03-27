#Requires -runasadministrator

<#
.SYNOPSIS
Sets Google Chrome (Enterprise) to kiosk mode and changes certain registry keys / values to prevent user escaping from browser.

.DESCRIPTION
Uses registry keys & values to set kiosk mode for browser (Google Chrome) and adds certain "fixes" preventing user escaping browser.

.OUTPUTS
Log file is stored to "C:\Temp\kioskMode.log"

.NOTES
    Version:          1.0
    Author            Eetu "Viru629" Lauren
    Creation Date:    17.12.2020
    Purpose/Change:   Started reworking old script

.EXAMPLE
Open powershell as admin and cd to script folder ex. cd "C:\Temp\kiosk"
And run main script ex. .\SetKioskMode.ps1

#>
Clear-Host

Start-Transcript -Path "C:\Temp\kioskSetup.log"

Write-Host "
 _____ _         _      _____       _        _____     _           
|  |  |_|___ ___| |_   |     |___ _| |___   |   __|___| |_ _ _ ___ 
|    -| | . |_ -| '_|  | | | | . | . | -_|  |__   | -_|  _| | | . |
|__|__|_|___|___|_,_|  |_|_|_|___|___|___|  |_____|___|_| |___|  _|
MADE BY: Eetu 'Virus629' Lauren                               |_|  
"

# Set current location variable
$currentDirectory = Get-Location

Import-Module -Name "$currentDirectory\modules\Get-Config" # Load conbfig module

# Dot-sourcing needed script files
. "$currentDirectory\scripts\SetUser.ps1"
. "$currentDirectory\scripts\InstallChrome.ps1"
. "$currentDirectory\scripts\SetRegistryKeys.ps1"
. "$currentDirectory\scripts\SetTasks.ps1"
. "$currentDirectory\scripts\SetPowerSettings.ps1"

# This is MAIN function
$userInput = Read-Host -Prompt "[+] Do you want to run kiosk mode setup? [yN]"

if ($userInput -match "[yY]") {
    # Load new registry hive to PsDrive
	New-PSDrive -PSProvider "Registry" -Name "HKU" -Root "HKEY_USERS" | Out-Null
    Write-Host "[+] INFORM: Mounting 'HKEY_USERS' to psdrive"

    # Function(s) from "SetUser.ps1"
    Add-User

    # Function(s) from "InstallChrome.ps1"
    Get-ChromePKG
    Install-Chrome

    # Functions from "SetRegistryKeys.ps1"
    Set-RegistryKeys
    Set-AutoLogin
    Set-RegistryScancodeMap

    # Functions from "SetTasks.ps1"
    Set-CrashHandlerTask
    Set-SessionRestartTask

    # Function(s) from "SetPowerSettings.ps1"
    Set-PowerSettings

    # Unmount 'HKEY_USERS' from PsDrive
    Remove-PSDrive -Name "HKU" | Out-Null
    Write-Host "[+] INFORM: Unmouting 'HKEY_USERS' from psdrive"

    Start-Sleep -Milliseconds 5000
    Write-Host "[+] INFORM: Kiosk mode setup has completed, rebooting..."
    Restart-Computer -Force
} else {
    Write-Host "[+] INFORM: Exiting..."
    exit
}

Stop-Transcript