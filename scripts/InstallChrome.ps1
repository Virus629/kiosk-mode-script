$currentDirectory = Get-Location

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