<#
.DESCRIPTION
This module handles editing & importing few task to task scheduler + copying powershell script to user home folder

#>
$currentDirectory = Get-Location


# This copies crash handler script to user home folder
function Set-CrashHandlerScript {
	$userName = Get-Config -Value "UserName"

	Copy-Item -Path "$currentDirectory\resources\ChromeCrashHandler.ps1" -Destination "C:\Users\$userName\ChromeCrashHandler.ps1" # Copy script to user home folder
}

# Creates new task to task scheduler which will handle chrome crasher or any other source of closing
function Set-CrashHandlerTask {
	$userName = Get-Config -Value "UserName"
	$userPasswd = Get-Variable -Name "userPasswd" -Scope global
	
	$userSID = (New-Object Security.Principal.NTaccount($userName)).Translate([Security.Principal.Securityidentifier]).Value
	
	# Take backup of original file
	Copy-Item -Path "$currentDirectory\resources\ChromeCrashHandler.xml" -Destination "$currentDirectory\resources\ChromeCrashHandlerImport.xml"
	
	# Edits new .xml file
	((Get-Content -Path "$currentDirectory\resources\ChromeCrashHandlerImport.xml" -Raw) -replace '_USERSID_', $userSID) | Set-Content -Path "$currentDirectory\resources\ChromeCrashHandlerImport.xml"

	$tempFile = "$currentDirectory\resources\ChromeCrashHandlerImport.xml"
	
	# Import new autostart task to task scheduler
	#Invoke-Command { schtasks.exe /Create /RU $env:COMPUTERNAME\$userName /RP $userPasswd.Value /IT /XML $tempFile /tn "Chrome Crash Handler" }
	Register-ScheduledTask -TaskName "Chrome Crash Handler" -Xml (Get-Content $tempFile | Out-String) -User $env:COMPUTERNAME\$userName -Password $userPasswd.Value | Out-Null
	
	Write-Host "[+] SUCCESS: Imported 'Chrome Crash Handler' to task scheduler"
	
	# Wait and delete edited file
	Start-Sleep -Milliseconds 5000 # Wait 5 secs
	Remove-Item -Path $tempFile -Force
	
	Write-Host "[+] INFORM: Deleted autostart temp files"

	Set-CrashHandlerScript
}


# This copies session restart script to user home folder
function Set-SessionRestartScript {
	$userName = Get-Config -Value "UserName"

	Copy-Item -Path "$currentDirectory\resources\ChromeSessionRestart.ps1" -Destination "C:\Users\$userName\ChromeSessionRestart.ps1" # Copy script to user home folder
}

# Creates new task to task scheduler which will handle chrome session restart, if computer is idle for 5 mins it will restart chrome
function Set-SessionRestartTask {
	$userName = Get-Config -Value "UserName"
	$userPasswd = Get-Variable -Name "userPasswd" -Scope global
	
	$userSID = (New-Object Security.Principal.NTaccount($userName)).Translate([Security.Principal.Securityidentifier]).Value
	
	# Take backup of original file
	Copy-Item -Path "$currentDirectory\resources\ChromeSessionRestart.xml" -Destination "$currentDirectory\resources\ChromeSessionRestartImport.xml"
	
	# Edits new .xml file
	((Get-Content -Path "$currentDirectory\resources\ChromeSessionRestartImport.xml" -Raw) -replace '_USERSID_', $userSID) | Set-Content -Path "$currentDirectory\resources\ChromeSessionRestartImport.xml"

	$tempFile = "$currentDirectory\resources\ChromeSessionRestartImport.xml"
	
	# Import new autostart task to task scheduler
	# Invoke-Command { schtasks.exe /Create /RU $env:COMPUTERNAME\$userName /RP $userPasswd.Value /IT /XML $tempFile /tn "Chrome Session Restarter" }
	Register-ScheduledTask -TaskName "Chrome Session Restarter" -Xml (Get-Content $tempFile | Out-String) -User $env:COMPUTERNAME\$userName -Password $userPasswd.Value | Out-Null

	Write-Host "[+] SUCCESS: Imported 'Chrome Session Restarter' to task scheduler"
	
	# Wait and delete edited file
	Start-Sleep -Milliseconds 5000 # Wait 5 secs
	Remove-Item -Path $tempFile -Force
	
	Write-Host "[+] INFORM: Deleted autostart temp files"

	Set-SessionRestartScript
}