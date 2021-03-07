# SOURCE: https://serverfault.com/a/186350
# Used to load config file
# USAGE: Get-Config -Value [string]<configName>
function Get-Config {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [string]$Value
    )

    $currentDirectory = Get-Location
    $configLocation = "$currentDirectory\config.psd1"

    $config = Import-PowerShellDataFile -Path $configLocation

    return $config.$Value
}

Export-ModuleMember -Function Get-Config