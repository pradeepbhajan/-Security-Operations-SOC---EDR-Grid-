# Sysmon Installation Script for Windows
# Part of Sentient Shield EDR

Write-Host "Installing Sysmon for deep visibility..." -ForegroundColor Green

# Download Sysmon
$sysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$sysmonZip = "$env:TEMP\Sysmon.zip"
$sysmonDir = "$env:TEMP\Sysmon"

Invoke-WebRequest -Uri $sysmonUrl -OutFile $sysmonZip

# Extract
Expand-Archive -Path $sysmonZip -DestinationPath $sysmonDir -Force

# Download Sysmon config
$configUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
$configFile = "$sysmonDir\sysmonconfig.xml"

Invoke-WebRequest -Uri $configUrl -OutFile $configFile

# Install Sysmon
Set-Location $sysmonDir
.\Sysmon64.exe -accepteula -i $configFile

Write-Host "Sysmon installed successfully!" -ForegroundColor Green
