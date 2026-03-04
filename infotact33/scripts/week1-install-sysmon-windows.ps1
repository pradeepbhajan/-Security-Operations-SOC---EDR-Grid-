# Week 1: Sysmon Installation Script for Windows
# Run as Administrator on Windows Server

Write-Host "=========================================="
Write-Host "  Sentient Shield - Sysmon Installation"
Write-Host "=========================================="
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Please run as Administrator" -ForegroundColor Red
    exit 1
}

# Step 1: Download Sysmon
Write-Host "[+] Downloading Sysmon..." -ForegroundColor Green
$sysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$sysmonZip = "$env:TEMP\Sysmon.zip"
$sysmonDir = "$env:TEMP\Sysmon"

try {
    Invoke-WebRequest -Uri $sysmonUrl -OutFile $sysmonZip -UseBasicParsing
    Write-Host "    Downloaded to: $sysmonZip" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Failed to download Sysmon" -ForegroundColor Red
    exit 1
}

# Step 2: Extract Sysmon
Write-Host "[+] Extracting Sysmon..." -ForegroundColor Green
if (Test-Path $sysmonDir) {
    Remove-Item -Path $sysmonDir -Recurse -Force
}
Expand-Archive -Path $sysmonZip -DestinationPath $sysmonDir -Force

# Step 3: Download Sysmon Configuration
Write-Host "[+] Downloading Sysmon configuration..." -ForegroundColor Green
$configUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
$configFile = "$sysmonDir\sysmonconfig.xml"

try {
    Invoke-WebRequest -Uri $configUrl -OutFile $configFile -UseBasicParsing
    Write-Host "    Using SwiftOnSecurity config" -ForegroundColor Gray
} catch {
    Write-Host "WARNING: Failed to download config, using default" -ForegroundColor Yellow
    $configFile = $null
}

# Step 4: Install Sysmon
Write-Host "[+] Installing Sysmon..." -ForegroundColor Green
Set-Location $sysmonDir

if ($configFile -and (Test-Path $configFile)) {
    & .\Sysmon64.exe -accepteula -i $configFile
} else {
    & .\Sysmon64.exe -accepteula -i
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "    Sysmon installed successfully" -ForegroundColor Gray
} else {
    Write-Host "ERROR: Sysmon installation failed" -ForegroundColor Red
    exit 1
}

# Step 5: Verify Installation
Write-Host "[+] Verifying Sysmon service..." -ForegroundColor Green
$sysmonService = Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue

if ($sysmonService -and $sysmonService.Status -eq "Running") {
    Write-Host "    Service Status: Running" -ForegroundColor Green
} else {
    Write-Host "ERROR: Sysmon service not running" -ForegroundColor Red
    exit 1
}

# Step 6: Check Event Log
Write-Host "[+] Checking Sysmon event log..." -ForegroundColor Green
$events = Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 1 -ErrorAction SilentlyContinue

if ($events) {
    Write-Host "    Event log is active" -ForegroundColor Green
} else {
    Write-Host "WARNING: No events yet (this is normal)" -ForegroundColor Yellow
}

# Step 7: Configure Wazuh Agent
Write-Host "[+] Configuring Wazuh agent for Sysmon..." -ForegroundColor Green
$wazuhConfig = "C:\Program Files (x86)\ossec-agent\ossec.conf"

if (Test-Path $wazuhConfig) {
    $configContent = Get-Content $wazuhConfig -Raw
    
    if ($configContent -notmatch "Microsoft-Windows-Sysmon/Operational") {
        $sysmonBlock = @"

  <!-- Sysmon Event Collection -->
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>
"@
        
        # Insert before closing </ossec_config>
        $configContent = $configContent -replace "</ossec_config>", "$sysmonBlock`n</ossec_config>"
        Set-Content -Path $wazuhConfig -Value $configContent
        
        Write-Host "    Wazuh config updated" -ForegroundColor Gray
        
        # Restart Wazuh agent
        Write-Host "[+] Restarting Wazuh agent..." -ForegroundColor Green
        Restart-Service WazuhSvc
        Start-Sleep -Seconds 3
        
        $wazuhService = Get-Service WazuhSvc
        if ($wazuhService.Status -eq "Running") {
            Write-Host "    Wazuh agent restarted" -ForegroundColor Green
        }
    } else {
        Write-Host "    Sysmon already configured in Wazuh" -ForegroundColor Gray
    }
} else {
    Write-Host "WARNING: Wazuh config not found at $wazuhConfig" -ForegroundColor Yellow
}

# Step 8: Generate Test Event
Write-Host "[+] Generating test event..." -ForegroundColor Green
Start-Process notepad.exe
Start-Sleep -Seconds 2
Stop-Process -Name notepad -Force -ErrorAction SilentlyContinue

# Final Summary
Write-Host ""
Write-Host "=========================================="
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "=========================================="
Write-Host ""
Write-Host "Sysmon Status:"
Get-Service Sysmon64 | Format-Table -AutoSize
Write-Host ""
Write-Host "Recent Sysmon Events:"
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 3 | Format-Table TimeCreated, Id, Message -AutoSize
Write-Host ""
Write-Host "Next Steps:"
Write-Host "1. Check Wazuh Dashboard for Sysmon events"
Write-Host "2. Filter by: data.win.system.channel: Microsoft-Windows-Sysmon/Operational"
Write-Host "3. Look for Event ID 1 (Process Creation)"
Write-Host ""
Write-Host "=========================================="
