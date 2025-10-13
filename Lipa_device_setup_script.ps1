# Software Installation Script using Winget
# Run this script as Administrator

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "System Configuration Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change device name
$currentComputerName = $env:COMPUTERNAME
Write-Host "Current device name: $currentComputerName" -ForegroundColor Yellow
Write-Host ""

$changeComputerName = Read-Host "Do you want to change the device name? (Y/N)"

if ($changeComputerName -eq "Y" -or $changeComputerName -eq "y") {
    $newComputerName = Read-Host "Enter new device name"
    
    if ($newComputerName -and $newComputerName -ne $currentComputerName) {
        try {
            Rename-Computer -NewName $newComputerName -Force
            Write-Host "✓ Device name will be changed to '$newComputerName' after restart" -ForegroundColor Green
            $requiresRestart = $true
        }
        catch {
            Write-Host "✗ Error changing device name: $_" -ForegroundColor Red
        }
    } elseif ($newComputerName -eq $currentComputerName) {
        Write-Host "Device name is already '$currentComputerName'" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Starting software installation..." -ForegroundColor Green
Write-Host ""

# Define packages to install with their Winget IDs
$packages = @(
    @{Name="RustDesk"; ID="RustDesk.RustDesk"},
    @{Name="Mozilla Firefox"; ID="Mozilla.Firefox"},
    @{Name="Google Chrome"; ID="Google.Chrome"},
    @{Name="Foxit PDF Reader"; ID="Foxit.FoxitReader"},
    @{Name="Adobe Acrobat Reader"; ID="Adobe.Acrobat.Reader.64-bit"},
    @{Name="HP Image Assistant"; ID="HP.ImageAssistant"}
)

# Install each package
foreach ($pkg in $packages) {
    Write-Host "Installing $($pkg.Name)..." -ForegroundColor Cyan
    
    try {
        winget install --id $($pkg.ID) --silent --accept-package-agreements --accept-source-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $($pkg.Name) installed successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ $($pkg.Name) installation failed or was already installed" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "✗ Error installing $($pkg.Name): $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "Installation process completed!" -ForegroundColor Green
Write-Host ""

# Disable Fast Startup
Write-Host "Disabling Fast Startup..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    $regName = "HiberbootEnabled"
    
    Set-ItemProperty -Path $regPath -Name $regName -Value 0 -Type DWord
    
    Write-Host "✓ Fast Startup has been disabled" -ForegroundColor Green
    Write-Host "  (Change will take effect after restart)" -ForegroundColor Yellow
}
catch {
    Write-Host "✗ Error disabling Fast Startup: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "User Account Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configure ClientAdmin account password
$configureClientAdmin = Read-Host "Do you want to configure the ClientAdmin account password? (Y/N)"

if ($configureClientAdmin -eq "Y" -or $configureClientAdmin -eq "y") {
    Write-Host ""
    Write-Host "Setting password for ClientAdmin account..." -ForegroundColor Cyan
    
    # Check if ClientAdmin account exists
    try {
        $clientAdminExists = Get-LocalUser -Name "ClientAdmin" -ErrorAction SilentlyContinue
        
        if ($clientAdminExists) {
            $clientAdminPassword = Read-Host "Enter new password for ClientAdmin" -AsSecureString
            $clientAdminPasswordConfirm = Read-Host "Confirm password" -AsSecureString
            
            # Convert SecureString to plain text for comparison
            $pwd1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientAdminPassword))
            $pwd2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientAdminPasswordConfirm))
            
            if ($pwd1 -eq $pwd2) {
                Set-LocalUser -Name "ClientAdmin" -Password $clientAdminPassword
                Write-Host "✓ ClientAdmin password has been updated" -ForegroundColor Green
            } else {
                Write-Host "✗ Passwords do not match. ClientAdmin password was not changed." -ForegroundColor Red
            }
        } else {
            Write-Host "✗ ClientAdmin account does not exist on this system" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "✗ Error configuring ClientAdmin account: $_" -ForegroundColor Red
    }
}

Write-Host ""

# Create new local user
$createLocalUser = Read-Host "Do you want to create a new local user account? (Y/N)"

if ($createLocalUser -eq "Y" -or $createLocalUser -eq "y") {
    Write-Host ""
    $newUsername = Read-Host "Enter username for the new local user"
    
    if ($newUsername) {
        try {
            # Check if user already exists
            $userExists = Get-LocalUser -Name $newUsername -ErrorAction SilentlyContinue
            
            if ($userExists) {
                Write-Host "✗ User '$newUsername' already exists" -ForegroundColor Yellow
            } else {
                $newUserPassword = Read-Host "Enter password for $newUsername" -AsSecureString
                $newUserPasswordConfirm = Read-Host "Confirm password" -AsSecureString
                
                # Convert SecureString to plain text for comparison
                $newPwd1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newUserPassword))
                $newPwd2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newUserPasswordConfirm))
                
                if ($newPwd1 -eq $newPwd2) {
                    # Create the user
                    New-LocalUser -Name $newUsername -Password $newUserPassword -FullName $newUsername -Description "Local Administrator Account"
                    Write-Host "✓ User '$newUsername' has been created" -ForegroundColor Green
                    
                    # Add to Administrators group
                    Add-LocalGroupMember -Group "Administrators" -Member $newUsername
                    Write-Host "✓ User '$newUsername' has been added to the Administrators group" -ForegroundColor Green
                } else {
                    Write-Host "✗ Passwords do not match. User was not created." -ForegroundColor Red
                }
            }
        }
        catch {
            Write-Host "✗ Error creating user account: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Windows Updates
$installUpdates = Read-Host "Do you want to install Windows Updates now? (Y/N)"

if ($installUpdates -eq "Y" -or $installUpdates -eq "y") {
    Write-Host ""
    Write-Host "Checking for Windows Updates..." -ForegroundColor Cyan
    Write-Host "This may take several minutes..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        # Check if PSWindowsUpdate module is installed
        $psWindowsUpdate = Get-Module -ListAvailable -Name PSWindowsUpdate
        
        if (-not $psWindowsUpdate) {
            Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Cyan
            Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
            Write-Host "✓ PSWindowsUpdate module installed" -ForegroundColor Green
            Write-Host ""
        }
        
        # Import the module
        Import-Module PSWindowsUpdate
        
        # Get available updates
        Write-Host "Scanning for available updates..." -ForegroundColor Cyan
        $updates = Get-WindowsUpdate
        
        if ($updates.Count -eq 0) {
            Write-Host "✓ No updates available. System is up to date!" -ForegroundColor Green
        } else {
            Write-Host "Found $($updates.Count) update(s)" -ForegroundColor Yellow
            Write-Host ""
            
            # Install updates
            Write-Host "Installing updates..." -ForegroundColor Cyan
            Write-Host "NOTE: This process may take a while depending on the number and size of updates" -ForegroundColor Yellow
            Write-Host ""
            
            Install-WindowsUpdate -AcceptAll -AutoReboot:$false -Verbose
            
            Write-Host ""
            Write-Host "✓ Windows Updates installed successfully" -ForegroundColor Green
            
            # Check if restart is required
            $rebootRequired = Get-WURebootStatus -Silent
            if ($rebootRequired) {
                Write-Host "⚠ A restart is required to complete the updates" -ForegroundColor Yellow
                $requiresRestart = $true
            }
        }
    }
    catch {
        Write-Host "✗ Error installing Windows Updates: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "You can manually check for updates in Windows Settings > Update & Security > Windows Update" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Run HP Image Assistant
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HP Image Assistant" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$runHPIA = Read-Host "Do you want to run HP Image Assistant to install HP drivers and updates? (Y/N)"

if ($runHPIA -eq "Y" -or $runHPIA -eq "y") {
    Write-Host ""
    Write-Host "Locating HP Image Assistant..." -ForegroundColor Cyan
    
    try {
        # Standard installation path for HP Image Assistant
        $hpiaPath = "C:\SWSetup\HPImageAssistant\HPImageAssistant.exe"
        
        if (Test-Path $hpiaPath) {
            Write-Host "✓ Found HP Image Assistant at: $hpiaPath" -ForegroundColor Green
            Write-Host ""
            Write-Host "Launching HP Image Assistant..." -ForegroundColor Cyan
            Write-Host "Please complete the driver installation in the HP Image Assistant window" -ForegroundColor Yellow
            Write-Host ""
            
            # Run HP Image Assistant
            Start-Process -FilePath $hpiaPath -Wait
            
            Write-Host ""
            Write-Host "✓ HP Image Assistant completed" -ForegroundColor Green
        } else {
            Write-Host "✗ HP Image Assistant executable not found at: $hpiaPath" -ForegroundColor Red
            Write-Host "Please ensure HP Image Assistant was installed correctly" -ForegroundColor Yellow
            Write-Host "You can run it manually from the Start Menu" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "✗ Error running HP Image Assistant: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All Tasks Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($requiresRestart) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "RESTART REQUIRED" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "A restart is required for the following changes:" -ForegroundColor Yellow
    if ($changeComputerName -eq "Y" -or $changeComputerName -eq "y") {
        Write-Host "  - Device name change" -ForegroundColor Yellow
    }
    if ($installUpdates -eq "Y" -or $installUpdates -eq "y") {
        Write-Host "  - Windows Updates" -ForegroundColor Yellow
    }
    Write-Host ""
    
    $restartNow = Read-Host "Would you like to restart now? (Y/N)"
    if ($restartNow -eq "Y" -or $restartNow -eq "y") {
        Write-Host "Restarting in 10 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

pause
