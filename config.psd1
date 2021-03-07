<#
.DESCRIPTION
This file is config for the kiosk setup script

#>

@{
    UserName  = "kiosk"
    ShellSite = "http://example.com/kiosk.php?c=" + $($env:COMPUTERNAME) # e.x http://example.com/kiosk.php?c=COMPUTER_123
}