do {
    $isRunning = Get-Process chrome.exe -ErrorAction SilentlyContinue

    if (-ne $isRunning) {
        Start-Process chrome.exe
    }

    Start-Sleep -Seconds 30 # Check every 30 seconds if chrome is running
} while ($true)