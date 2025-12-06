# Windows Updates Installation Script
# This script installs available Windows updates via PowerShell

# Requires administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

Write-Host "Windows Updates Installation Script" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Install NuGet provider if not already installed
Write-Host "Checking for NuGet provider..." -ForegroundColor Yellow
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Write-Host "Installing NuGet provider..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false | Out-Null
    Write-Host "NuGet provider installed successfully." -ForegroundColor Green
}

# Install PSWindowsUpdate module if not already installed
Write-Host "Checking for PSWindowsUpdate module..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Yellow
    Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    Write-Host "PSWindowsUpdate module installed successfully." -ForegroundColor Green
}

# Import the module
Import-Module PSWindowsUpdate

Write-Host ""
Write-Host "Checking for available updates..." -ForegroundColor Yellow
Write-Host ""

# Get list of available updates
$updates = Get-WindowsUpdate -MicrosoftUpdate

if ($updates.Count -eq 0) {
    Write-Host "No updates available. Your system is up to date!" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($updates.Count) update(s) available:" -ForegroundColor Green
Write-Host ""

# Display available updates
$updates | ForEach-Object {
    Write-Host "  - $($_.Title)" -ForegroundColor White
}

Write-Host ""
$response = Read-Host "Do you want to install these updates? (Y/N)"

if ($response -ne "Y" -and $response -ne "y") {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Installing updates..." -ForegroundColor Yellow
Write-Host ""

# Install all available updates
Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -IgnoreReboot

Write-Host ""
Write-Host "Updates installation completed!" -ForegroundColor Green
Write-Host "Your system may restart to complete the installation." -ForegroundColor Cyan