<#
.SYNOPSIS
    Retrieves detailed system information
.DESCRIPTION
    This script gathers comprehensive system information including OS details, hardware specs, and optionally disk information
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ComputerName = "localhost",
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeDisk
)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host "                   SYSTEM INFORMATION REPORT                   "
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host ""

Write-Host "Computer Name    : $ComputerName"

try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $proc = Get-CimInstance Win32_Processor | Select-Object -First 1
    
    Write-Host "OS Version       : $($os.Caption)"
    Write-Host "OS Build         : $($os.BuildNumber)"
    Write-Host "Processor        : $($proc.Name)"
    Write-Host "Total Memory     : $([math]::Round($cs.TotalPhysicalMemory/1GB, 1)) GB"
    
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host "System Uptime    : $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
    
    if ($IncludeDisk) {
        Write-Host ""
        Write-Host "[DISK INFORMATION]"
        Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null } | ForEach-Object {
            $total = [math]::Round($_.Used/1GB + $_.Free/1GB, 0)
            $free = [math]::Round($_.Free/1GB, 0)
            $used = [math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 0)
            Write-Host "Drive $($_.Name): - Total: $total GB | Free: $free GB | Used: $used%"
        }
    }
    
    Write-Host ""
    Write-Host "[SUCCESS] System information retrieved successfully."
} catch {
    Write-Host "[ERROR] Failed to retrieve system information: $_"
}
