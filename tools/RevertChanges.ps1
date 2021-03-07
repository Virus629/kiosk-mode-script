<#
.SYNOPSIS
This script is used when kiosk settings needs to be reverted

.DESCRIPTION
This script is mostly used in development to easily remove kiosk settings
You can ignore all errors if there is any (It shouldn create any (except Unregister-ScheduledTask))

#>
$ErrorActionPreference = 'SilentlyContinue'

$currentDirectory = Get-Location
Import-Module -Name "$currentDirectory\modules\Get-Config" # Load config module

Write-Host "BE AWARE! THIS WILL ALSO UNINSTALL CHROME!" -ForegroundColor Red
$userInput = Read-Host -Prompt "[+] Do you want to revert kiosk setup changes? (REBOOT AT END) [yN]"

if ($userInput -match "[yY]") {
    $userName = Get-Config -Value "UserName"
    $userSID = (New-Object Security.Principal.NTaccount($userName)).Translate([Security.Principal.Securityidentifier]).Value

    New-PSDrive -Name "HKU" -PSProvider "Registry" -Root "HKEY_USERS" | Out-Null

    $logonRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

    Remove-ItemProperty -Path $logonRegPath -Name "AutoAdminLogon" -Force
    Remove-ItemProperty -Path $logonRegPath -Name "DefaultDomainName" -Force
    Remove-ItemProperty -Path $logonRegPath -Name "DefaultPassword" -Force
    Remove-ItemProperty -Path $logonRegPath -Name "DefaultUserName" -Force

    $scancodeRegPath = "HKLM:\System\CurrentControlSet\Control\Keyboard Layout"

    Remove-ItemProperty -Path $scancodeRegPath -Name "Scancode Map" -Force

    Unregister-ScheduledTask -TaskName "Chrome Crash Handler" -Confirm:$false
    Unregister-ScheduledTask -TaskName "Chrome Session Restarter" -Confirm:$false

    Start-Sleep -Milliseconds 2000
    [gc]::collect()

    Start-Process "cmd.exe" -ArgumentList "/c reg unload 'HKU:\$userSID'"

    Remove-Item -Path "C:\Users\$userName\" -Recurse -Force

    Remove-LocalUser -Name $userName

    Remove-PSDrive -Name "HKU" | Out-Null

    $chromeUninstaller = (Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Google Chrome"}).Uninstall()

    if ($chromeUninstaller.ReturnValue -eq 0) {
        Write-Host "[+] SUCCESS: Chrome uninstalled successfully!"
    } else {
        Write-Host "[+] ERROR: There was problem uninstalling chrome!"
        Write-Host "[+] ERROR: Chrome uninstaller return code: $($chromeUninstaller.ReturnValue)"
    }

    Write-Host "[+] Done! Rebooting..."

    Restart-Computer -Force
} else {
    Write-Host "[+] Exiting..."
    exit
}