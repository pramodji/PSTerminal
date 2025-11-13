<#
.SYNOPSIS
    Tests network connectivity to hosts
.DESCRIPTION
    Performs comprehensive network connectivity tests including DNS resolution and port checks
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$HostName,
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 80,
    
    [Parameter(Mandatory=$false)]
    [int]$Timeout = 5000
)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host "                   NETWORK CONNECTION TEST                     "
Write-Host "═══════════════════════════════════════════════════════════════"
Write-Host ""

Write-Host "Target Host: $HostName"
Write-Host "Port: $Port"
Write-Host "Timeout: ${Timeout}ms"
Write-Host ""

try {
    # DNS Resolution
    Write-Host "[TESTING] Resolving hostname..."
    $resolved = [System.Net.Dns]::GetHostAddresses($HostName) | Select-Object -First 1
    Write-Host "[OK] Resolved to: $($resolved.IPAddressToString)"
    Write-Host ""
    
    # Port connectivity
    Write-Host "[TESTING] Checking port connectivity..."
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $connect = $tcpClient.BeginConnect($HostName, $Port, $null, $null)
    $wait = $connect.AsyncWaitHandle.WaitOne($Timeout, $false)
    
    if ($wait) {
        try {
            $tcpClient.EndConnect($connect)
            Write-Host "[OK] Port $Port is open and accepting connections"
        } catch {
            Write-Host "[ERROR] Port $Port is closed or not responding"
            $tcpClient.Close()
            exit 1
        }
    } else {
        Write-Host "[ERROR] Connection timeout"
        $tcpClient.Close()
        exit 1
    }
    
    $tcpClient.Close()
    Write-Host ""
    
    # Ping test
    Write-Host "[TESTING] Measuring response time..."
    $ping = New-Object System.Net.NetworkInformation.Ping
    $results = @()
    
    for ($i = 1; $i -le 3; $i++) {
        $result = $ping.Send($HostName, $Timeout)
        if ($result.Status -eq 'Success') {
            $results += $result.RoundtripTime
            Write-Host "  Attempt ${i}: $($result.RoundtripTime)ms"
        }
    }
    
    if ($results.Count -gt 0) {
        $avg = [math]::Round(($results | Measure-Object -Average).Average, 2)
        Write-Host "  Average: ${avg}ms"
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════"
    Write-Host "  CONNECTION STATUS: ✓ SUCCESSFUL                             "
    Write-Host "═══════════════════════════════════════════════════════════════"
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Network test failed: $_"
    exit 1
}
