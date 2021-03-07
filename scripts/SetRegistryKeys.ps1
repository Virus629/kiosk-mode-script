<#
.DESCRIPTION
This module handles registry editing, it sets user new shell & enables autologin.
#>

$currentDirectory = Get-Location

Import-Module -Name "$currentDirectory\modules\Get-Config" # Load config module
Import-Module -Name "$currentDirectory\modules\Test-RegistryValues" # Load Test reg value module


# Sets keys that live under 'HKEY_CURRENT_USER'
# ex. Disabling Task Manager & Replaces user shell
function Set-RegistryKeys {
	$userName = Get-Config -Value "UserName"
	$userSID = (New-Object Security.Principal.NTaccount($userName)).Translate([Security.Principal.Securityidentifier]).Value
	
	# Load user profile to registry "HKEY_USERS\SID"
	Start-Process "cmd.exe" -ArgumentList "/c reg load HKU\$userSID C:\Users\$userName\NTUSER.DAT"

	Start-Sleep -Milliseconds 2500 # This only works sometimes???

	$regPath = "HKU:\$userSID\Software\Microsoft\Windows\CurrentVersion\Policies"

	# Check if system value exist under 'policies'
	$sysRegPath = Test-Path -Path "$regPath\System"
	
	if ($sysRegPath -eq $true) {
		Write-Host "[+] INFORM: System key already exists, ignoring..."
	} else {
		New-Item -Path $regPath -Name "System" # Create new reg key
	}

	# Disable task manager via registry
	$tskMgrRegPath = Test-RegistryValue -Key "$regPath\System" -Value "DisableTaskMgr"
	
	if ($tskMgrRegPath -eq $true) {
		Write-Host "[+] INFORM: Task manager is already disabled, ignoring..."
	} else {
		New-ItemProperty "$regPath\System" -Name "DisableTaskMgr" -Value 1 -PropertyType "DWord"
	}
	
	# Disable 'Windows + L' via registry
	$winlRegPath = Test-RegistryValue -Key "$regPath\System" -Value "DisableLockWorkstation"

	if ($winlRegPath -eq $true) {
		Write-Host "[+] INFORM: 'Windows + L' is already disabled, ignoring..."
	} else {
		New-ItemProperty "$regPath\System" -Name "DisableLockWorkstation" -Value 1 -PropertyType "DWord"
	}
	
	# ---------------- #
	# ---------------- #
	# ---------------- #

	# Set custom shell e.x 'explorer.exe ==> chrome.exe'
	$winLogonRegPath = "HKU:\$userSID\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

	$shellArgs = '--disable-session-crashed-bubble --incognito --chrome-frame --kiosk' # These are chrome startup parameters
	$shellSite = Get-Config -Value "ShellSite"
	$shellFullPath = '"C:\Program Files\Google\Chrome\Application\chrome.exe" ' + $shellArgs + ' ' + $shellSite
	
	$shellRegPath = Test-RegistryValue -Key $winLogonRegPath -Value "Shell"
	
	if ($shellRegPath -eq $true) {
		Write-Host "[+] INFORM: Shell is already changed, ignoring..."
	} else {
		New-ItemProperty $winLogonRegPath -Name "Shell" -Value $shellFullPath -PropertyType "String"
	}

	Start-Sleep -Milliseconds 2000 # Wait few seconds before cleaning & unloading hive
	[gc]::collect() # SOURCE: https://stackoverflow.com/a/63242245/9711606

	# Unmount user registry hive after reg key writing
	Start-Process "cmd.exe" -ArgumentList "/c reg unload HKU\$userSID"
}


# Set registry keys that allow user autlogin
function Set-AutoLogin {
	$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
	
	$userPasswd = Get-Variable -Name "userPasswd" -Scope global # Gets value from "global" scope
	$userName = Get-Config -Value "UserName"

	# Auto login variables
	$autoAdminLogon = @('AutoAdminLogon', '1')
	$defaultDomain = @('DefaultDomainName', '.\')
	$defaultPasswd = @('DefaultPassword', $userPasswd.Value)
	$defaultUsername = @('DefaultUserName', $userName)
	
	# Sets default login mode
	$autoAdminLogonReg = Test-RegistryValue -Key $regPath -Value $autoAdminLogon[0]

	if ($autoAdminLogonReg -eq $true) {
		Set-ItemProperty -Path $regPath -Name $autoAdminLogon[0] -Value $autoAdminLogon[1]
		Write-Host "[+] INFORM: Setting key:" $autoAdminLogon[0] "to:" $autoAdminLogon[1]
	} else {
		New-ItemProperty -Path $regPath -Name $autoAdminLogon[0] -Value $autoAdminLogon[1] -PropertyType 'String'
		Write-Host "[+] INFORM: Creating new key:" $autoAdminLogon[0] "to:" $autoAdminLogon[1]
	}

	# Sets default login domain
	$defaultDomainReg = Test-RegistryValue -Key $regPath -Value $defaultDomain[0]

	if ($defaultDomainReg -eq $true) {
		Set-ItemProperty -Path $regPath -Name $defaultDomain[0] -Value $defaultDomain[1]
		Write-Host "[+] INFORM: Setting key:" $defaultDomain[0] "to:" $defaultDomain[1]
	} else {
		New-ItemProperty -Path $regPath -Name $defaultDomain[0] -Value $defaultDomain[1] -PropertyType 'String'
		Write-Host "[+] INFORM: Creating new key:" $defaultDomain[0] "to:" $defaultDomain[1]
	}
	
	# Sets default login password
	$defaultPasswdReg = Test-RegistryValue -Key $regPath -Value $defaultPasswd[0]

	if ($defaultPasswdReg -eq $true) {
		Set-ItemProperty -Path $regPath -Name $defaultPasswd[0] -Value $defaultPasswd[1]
		Write-Host "[+] INFORM: Setting key:" $defaultPasswd[0] "to:" $defaultPasswd[1]
	} else {
		New-ItemProperty -Path $regPath -Name $defaultPasswd[0] -Value $defaultPasswd[1] -PropertyType 'String'
		Write-Host "[+] INFORM: Creating new key:" $defaultPasswd[0] "to:" $defaultPasswd[1]
	}
	
	# Sets default login username
	$defaultUsernameReg = Test-RegistryValue -Key $regPath -Value $defaultUsername[0]

	if ($defaultUsernameReg -eq $true) {
		Set-ItemProperty -Path $regPath -Name $defaultUsername[0] -Value $defaultUsername[1]
		Write-Host "[+] INFORM: Setting key:" $defaultUsername[0] "to:" $defaultUsername[1]
	} else {
		New-ItemProperty -Path $regPath -Name $defaultUsername[0] -Value $defaultUsername[1] -PropertyType 'String'
		Write-Host "[+] INFORM: Creating new key:" $defaultUsername[0] "to:" $defaultUsername[1]
	}
}

# Disables DEL (CTRL ALT DEL) & F4 (ALT F4)
function Set-RegistryScancodeMap {
	$regPath = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout' # This path contains scancode map value

	$regValue = "00,00,00,00,00,00,00,00,03,00,00,00,00,00,3E,00,00,00,53,E0,00,00,00,00"
	$regToHex = $regValue.Split(',') | ForEach-Object { "0x$_" } # SOURCE: https://stackoverflow.com/a/33586470/9711606
	
	$testRegPath = Test-RegistryValue -Key $regPath -Value "Scancode Map"
	
	if ($testRegPath -eq $true) {
		Write-Host "[+] INFORM: Scancode is already edited, ignoring..."
	} else {
		New-ItemProperty $regPath -Name 'Scancode Map' -Value $regToHex -PropertyType 'Binary'
	}
}