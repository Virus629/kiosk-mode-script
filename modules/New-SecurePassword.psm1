# SOURCE: https://powershell.org/forums/topic/generating-random-password-without-special-characters/#post-237652
# Used to genereate random password
# USAGE: New-SecurePassword -PasswordLenght [int]<lenght>
function New-SecurePassword {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [int]$PasswordLenght
    )

    $Password = "!?@#$%^*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray()
	($Password | Get-Random -Count $PasswordLenght) -Join ''
}

Export-ModuleMember -Function New-SecurePassword