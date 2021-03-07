# SOURCE FOR THIS CODE: https://gist.github.com/wendelb/1c364bb1a36ca5916ca4

# SNIPPER SOURCE: http://stackoverflow.com/a/15846912
# DO NOT EDIT THIS #
Add-Type @'
    using System;
    using System.Diagnostics;
    using System.Runtime.InteropServices;

    namespace PInvoke.Win32 {

        public static class UserInput {

            [DllImport("user32.dll", SetLastError=false)]
            private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

            [StructLayout(LayoutKind.Sequential)]
            private struct LASTINPUTINFO {
                public uint cbSize;
                public int dwTime;
            }

            public static DateTime LastInput {
                get {
                    DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                    DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                    return lastInput;
                }
            }

            public static TimeSpan IdleTime {
                get {
                    return DateTime.UtcNow.Subtract(LastInput);
                }
            }

            public static int LastInputTicks {
                get {
                    LASTINPUTINFO lii = new LASTINPUTINFO();
                    lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                    GetLastInputInfo(ref lii);
                    return lii.dwTime;
                }
            }
        }
    }
'@
# NOW YOU CAN EDIT #

$currentDirectory = Get-Location

Import-Module -Name "$currentDirectory\modules\Get-Config" # Load config module

# How many minutes computer is in idle before restarting chrome process
$kioskIdleTimeout = New-TimeSpan -Minutes 5

# Has chrome restarted
$hasRestarted = 0

do {
    $idleTime = [PInvoke.Win32.UserInput]::IdleTime # Get user idle time

    $shellArgs = '--disable-session-crashed-bubble --incognito --chrome-frame --kiosk'
    $shellSite = Get-Config -Value "ShellSite"

    # Debug MSG
    #Write-Host ("Idle for " + $idleTime.Days + " days, " + $idleTime.Hours + " hours, " + $idleTime.Minutes + " minutes, " + $idleTime.Seconds + " seconds.")

    if (($hasRestarted -eq 0) -And ($idleTime -gt $kioskIdleTimeout)) { # If idleTime (in minutes) is greater than kioskIdleTimeout ==> restart chrome
        Write-Host "[+] INFORM: Restarting chrome..."
        Invoke-Command { Taskkill /im chrome.exe /f } # Kill chrome
        Start-Process 'chrome.exe' -ArgumentList "/q $shellArgs $shellSite"
        $hasRestarted = 1
    }

    if ($idleTime -lt $kioskIdleTimeout) {
        $hasRestarted = 0
    }

    Start-Sleep -Milliseconds 10000 # Wait 10 secs so we dont burn cpu
} while ($true)
