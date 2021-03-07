$currentDirectory = Get-Location

# Prevent computer going sleep
# SOURCE: https://ss64.com/nt/powercfg.html
function Set-PowerSettings {
    Invoke-Command -ScriptBlock { 
        Powercfg /Change monitor-timeout-ac 0
        Powercfg /Change monitor-timeout-dc 0
        Powercfg /Change standby-timeout-ac 0
        Powercfg /Change standby-timeout-dc 0
        Powercfg /Change hibernate-timeout-ac 0
        Powercfg /Change hibernate-timeout-dc 0
    }
}