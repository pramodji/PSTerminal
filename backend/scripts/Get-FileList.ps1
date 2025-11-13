<#
.SYNOPSIS
    Lists files in a directory with filters
.DESCRIPTION
    Scans a directory and lists files matching the specified filter pattern
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$false)]
    [string]$Filter = "*.*",
    
    [Parameter(Mandatory=$false)]
    [switch]$Recurse
)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host "                      FILE LIST REPORT                         "
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host ""

Write-Host "Scanning Path: $Path"
Write-Host "Filter: $Filter"
Write-Host "Recursive: $(if($Recurse){'YES'}else{'NO'})"
Write-Host ""

try {
    if (-not (Test-Path $Path)) {
        Write-Host "[ERROR] Path does not exist: $Path"
        exit 1
    }
    
    $files = if ($Recurse) {
        Get-ChildItem -Path $Path -Filter $Filter -File -Recurse -ErrorAction SilentlyContinue
    } else {
        Get-ChildItem -Path $Path -Filter $Filter -File -ErrorAction SilentlyContinue
    }
    
    Write-Host "┌─────────────────────────────────────────────────────────────────┐"
    Write-Host "│ Name                          Size        Modified            │"
    Write-Host "├─────────────────────────────────────────────────────────────────┤"
    
    $totalSize = 0
    $count = 0
    
    foreach ($file in $files | Select-Object -First 50) {
        $count++
        $totalSize += $file.Length
        
        $sizeMB = if ($file.Length -gt 1MB) {
            "$([math]::Round($file.Length/1MB, 1)) MB"
        } elseif ($file.Length -gt 1KB) {
            "$([math]::Round($file.Length/1KB, 1)) KB"
        } else {
            "$($file.Length) B"
        }
        
        $name = $file.Name.PadRight(28).Substring(0, 28)
        $size = $sizeMB.PadLeft(10)
        $modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
        
        Write-Host "│ $name  $size  $modified  │"
    }
    
    Write-Host "└─────────────────────────────────────────────────────────────────┘"
    Write-Host ""
    
    $totalSizeMB = [math]::Round($totalSize/1MB, 1)
    Write-Host "Total Files: $count | Total Size: $totalSizeMB MB"
    Write-Host ""
    Write-Host "[SUCCESS] File listing completed."
    
} catch {
    Write-Host "[ERROR] Failed to list files: $_"
}
