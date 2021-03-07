do {
    $isRunning = Get-Process chrome.exe -ErrorAction SilentlyContinue

    if (-ne $isRunning) {
        Start-Process chrome.exe
    }

    Start-Sleep -Milliseconds 30000 # Check every 30 seconds if chrome is running
} while ($true)