$currentDirectory = Get-Location

Import-Module -Name "$currentDirectory\modules\Get-Config" # Load config module
Import-Module -Name "$currentDirectory\modules\New-SecurePassword" # Load password module

# Used to create new local user with random password
function Add-User {
	# User variables, their scope is script
	$userName = Get-Config -Value "UserName" # Change username here
	$global:userPasswd = New-SecurePassword -PasswordLenght 20 # Random password, change password lenght here
	
	# Create new local user, where password is always random
    New-LocalUser -Name $userName -AccountNeverExpires:$true -PasswordNeverExpires:$true -UserMayNotChangePassword:$true -Description "Kiosk mode user" -Password (ConvertTo-SecureString -AsPlainText -Force $userPasswd) | Out-Null
	
	Write-Host "[+] INFORM: Creating new user: '$userName', with password: '$userPasswd'"
	
	# Create user home folder
	Write-Host "[+] INFORM: Generating user: '$userName' home folder..."
	$getPasswd = ConvertTo-SecureString -AsPlainText -Force $userPasswd
	$userCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $getPasswd
	Start-Process -FilePath 'cmd.exe' -Credential $userCredentials -ErrorAction SilentlyContinue -LoadUserProfile -NoNewWindow -ArgumentList "/c" -WorkingDirectory 'C:\Windows\System32' # Loads user home folder
}