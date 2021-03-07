$currentDirectory = Get-Location

Import-Module -Name "$currentDirectory\modules\Get-Config" # Load config module
Import-Module -Name "$currentDirectory\modules\New-SecurePassword" # Load password module

# Used to create new local user with random password
function Add-User {
	# User variables, their scope is script
	$global:userName = Get-Config -Config "UserName" # Change username here
	$global:userPasswd = New-SecurePassword -PasswordLenght 20 # Random password, change password lenght here
	
	# Create new local user, where password is always random
    New-LocalUser -Name $userName -AccountNeverExpires:$true -PasswordNeverExpires:$true -UserMayNotChangePassword:$true -Description "Kiosk mode user" -Password (ConvertTo-SecureString -AsPlainText -Force $userPasswd)
	
	Write-Host "[+] INFORM: Creating new user: '$userName', with password: '$userPasswd'"
	
	# Create user home folder
	Write-Host "[+] INFORM: Generating user: '$userName' home folder..."
	$getPasswd = ConvertTo-SecureString -AsPlainText -Force $userPasswd
	$userCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $getPasswd
	Start-Process 'cmd.exe' -ArgumentList "/c" -Credential $userCredentials -ErrorAction SilentlyContinue -LoadUserProfile -NoNewWindow # Loads user home folder
}

# Install Chrome Enterprise using msiexec
function Install-ChromeEnterprise {
	$installProcess = Start-Process msiexec.exe -ArgumentList "/i ""$currentDirectory\resources\googlechromestandaloneenterprise64.msi"" /qn /norestart" -NoNewWindow -Wait -PassThru
	
	Write-Host "[+] INFORM: Installing Chrome Enterprise"
	
	if ($installProcess.ExitCode -eq 0) { # Check which exit code was given
		Write-Host "[+] SUCCESS: Chrome Enterprise installed successfully!"
	} else {
		Write-Host "[+] ERROR: Something went wrong installing chrome..."
	}
}