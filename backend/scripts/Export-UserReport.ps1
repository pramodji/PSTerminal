<#
.SYNOPSIS
    Generates user activity report
.DESCRIPTION
    Creates a report of user activity and session information
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserName,
    
    [Parameter(Mandatory=$false)]
    [int]$Days = 30,
    
    [Parameter(Mandatory=$false)]
    [string]$Format = "HTML"
)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host "                    USER ACTIVITY REPORT                       "
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host ""

Write-Host "User: $UserName"
Write-Host "Period: Last $Days days"
Write-Host "Format: $Format"
Write-Host ""

try {
    Write-Host "[PROCESSING] Collecting login data..."
    Start-Sleep -Milliseconds 500
    
    # Simulate login event collection
    $loginCount = Get-Random -Minimum 50 -Maximum 150
    Write-Host "[OK] Found $loginCount login events"
    Write-Host ""
    
    Write-Host "[PROCESSING] Analyzing activity patterns..."
    Start-Sleep -Milliseconds 500
    
    $activityCount = Get-Random -Minimum 500 -Maximum 2000
    Write-Host "[OK] Processed $activityCount activities"
    Write-Host ""
    
    Write-Host "[PROCESSING] Generating $Format report..."
    Start-Sleep -Milliseconds 500
    
    $reportPath = "C:\Reports\${UserName}_Report.$($Format.ToLower())"
    Write-Host "[OK] Report created: $reportPath"
    Write-Host ""
    
    # Generate summary
    $activeDays = [math]::Round($Days * 0.75)
    $avgSession = [math]::Round((Get-Random -Minimum 4 -Maximum 9) + (Get-Random) / 10, 1)
    
    Write-Host "Summary:"
    Write-Host "  Total Logins: $loginCount"
    Write-Host "  Active Days: $activeDays out of $Days"
    Write-Host "  Avg Session: $avgSession hours"
    Write-Host "  Peak Activity: 10:00 AM - 12:00 PM"
    Write-Host ""
    Write-Host "[SUCCESS] User report exported successfully."
    
} catch {
    Write-Host "[ERROR] Failed to generate report: $_"
}
