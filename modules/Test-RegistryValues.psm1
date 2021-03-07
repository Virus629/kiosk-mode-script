# SOURCE: https://stackoverflow.com/a/5649710
# Used to test if registry value exists in registry
# USAGE: Test-RegistryValue -Key [string]<regKey> -Value [string]<regValue>
function Test-RegistryValue {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [string]$Key,

        [Parameter(Mandatory=$True)]
        [string]$Value
    )

    $exists = Get-ItemProperty -Path "$Key" -Name "$Value" -ErrorAction SilentlyContinue
    if (($null -ne $exists) -and ($exists.Length -ne 0)) {
        return $true
    }
    return $false
}

Export-ModuleMember -Function Test-RegistryValue