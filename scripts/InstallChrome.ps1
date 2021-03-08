$ProgressPreference = 'SilentlyContinue' # This helps getting better download speed
$currentDirectory = Get-Location

# Download chrome msi package
function Get-ChromePKG {
	Write-Host "[+] INFORM: Downloading Chrome Enterprise binary"

	Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi" -OutFile ".\resources\googlechromestandaloneenterprise64.msi"

	Write-Host "[+] SUCCESS: Chrome Enterprise binary downloaded successfully!"
}


# Install Chrome (Enterprise) using msiexec
function Install-Chrome {
	Write-Host "[+] INFORM: Installing Chrome Enterprise"
	
	$installProcess = Start-Process msiexec.exe -ArgumentList "/i ""$currentDirectory\resources\googlechromestandaloneenterprise64.msi"" /qn /norestart" -NoNewWindow -Wait -PassThru
	
	if ($installProcess.ExitCode -eq 0) { # Check which exit code was given
		Write-Host "[+] SUCCESS: Chrome installed successfully!"
	} else {
		Write-Host "[+] ERROR: Something went wrong installing chrome..."
	}
}