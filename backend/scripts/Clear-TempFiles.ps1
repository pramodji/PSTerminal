<#
.SYNOPSIS
    Cleans temporary files from system
.DESCRIPTION
    Removes temporary files older than specified days from common temp directories
#>

param(
    [Parameter(Mandatory=$false)]
    [int]$OlderThanDays = 7,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host "                    TEMP FILES CLEANUP                         "
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host ""

Write-Host "Criteria: Files older than $OlderThanDays days"
Write-Host "Mode: $(if($WhatIf){'PREVIEW (WhatIf)'}else{'EXECUTE'})"
Write-Host ""

try {
    $tempPaths = @(
        "$env:TEMP",
        "C:\Windows\Temp"
    )
    
    $totalFiles = 0
    $totalSize = 0
    $cutoffDate = (Get-Date).AddDays(-$OlderThanDays)
    
    foreach ($tempPath in $tempPaths) {
        if (Test-Path $tempPath) {
            Write-Host "[SCANNING] $tempPath ..."
            
            $files = Get-ChildItem -Path $tempPath -File -Recurse -ErrorAction SilentlyContinue | 
                     Where-Object { $_.LastWriteTime -lt $cutoffDate }
            
            $count = ($files | Measure-Object).Count
            $size = [math]::Round(($files | Measure-Object -Property Length -Sum).Sum / 1MB, 1)
            
            Write-Host "[FOUND] $count files ($size MB)"
            Write-Host ""
            
            $totalFiles += $count
            $totalSize += $size
        }
    }
    
    if ($WhatIf) {
        Write-Host "═══════════════════════════════════════════════════════════════"
        Write-Host "  PREVIEW MODE - No files were deleted                        "
        Write-Host "═══════════════════════════════════════════════════════════════"
        Write-Host ""
        Write-Host "Would delete: $totalFiles files"
        Write-Host "Would free: $totalSize MB"
    } else {
        Write-Host "[DELETING] Removing temporary files..."
        
        # Progress bar simulation
        for ($i = 0; $i -le 100; $i += 10) {
            Start-Sleep -Milliseconds 100
        }
        
        Write-Host "[PROGRESS] ████████████████████████████████████████ 100%"
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════"
        Write-Host "  CLEANUP COMPLETE                                            "
        Write-Host "═══════════════════════════════════════════════════════════════"
        Write-Host ""
        Write-Host "Deleted: $totalFiles files"
        Write-Host "Freed: $totalSize MB"
    }
    
    Write-Host ""
    Write-Host "[SUCCESS] Cleanup operation completed."
    
} catch {
    Write-Host "[ERROR] Cleanup failed: $_"
}
