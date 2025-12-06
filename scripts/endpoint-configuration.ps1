# Temp file for ticket information
$tempFile = "C:\temp\device_info.txt"
if (Test-Path $tempFile) {
    Clear-Content $tempFile
}
else {
    $tempDir = Split-Path -Path $tempFile -Parent
    if (-not (Test-Path -Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
    New-Item -ItemType File -Path $tempFile -Force | Out-Null
}

# Function to write ticket information to a temp file
function Write-TicketInfoToTempFile {
    param (
        [string]$Key,
        [string]$Value
    )
    "$Key=$Value" | Out-File -FilePath "C:\temp\device_info.txt" -Append
}

# Function to write progress messages
function Write-Progress-Message {
    param (
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host "`n$Message" -ForegroundColor $Color
    Write-Host ("=" * 80) -ForegroundColor DarkGray
}

# Function to set the device name interactively
function Set-DeviceName {
    Write-Progress-Message "Configuring Device Name" "Magenta"

    $currentName = (Get-ComputerInfo).CsName
    Write-Host "Current device name: $currentName" -ForegroundColor Yellow

    $newName = Read-Host "Enter the new device name (e.g., LIPA-PC-001)"
    
    if ([string]::IsNullOrWhiteSpace($newName)) {
        Write-Warning "Device name cannot be empty. Skipping device rename."
        return
    }

    if ($newName -eq $currentName) {
        Write-Host "New device name is the same as the current name. No change needed." -ForegroundColor Green
        Write-TicketInfoToTempFile -Key "DEVICENAME" -Value $currentName
        return
    }

    try {
        Rename-Computer -NewName $newName -Force -Confirm:$false
        Write-Host "✓ Device name changed to $newName. A restart is required for the change to take effect." -ForegroundColor Green
        Write-TicketInfoToTempFile -Key "DEVICENAME" -Value $newName
    }
    catch {
        Write-Warning "✗ Failed to change device name: $_"
    }
}

# Main configuration logic
Write-Progress-Message "Starting Endpoint Configuration Process" "Cyan"

# Call the function to set the device name
Set-DeviceName

# Function to get a valid password from the user
function Get-ValidPassword {
    param (
        [string]$username
    )

    while ($true) {
    Write-Host "Password options for ${username} :"
        Write-Host "1. Set a custom password"
        Write-Host "2. Skip"
        $choice = Read-Host "Enter your choice (1 or 2)"

        if ($choice -eq '2') {
            return @{ Secure = $null; Plain = $null }
        }

        if ($choice -eq '1') {
            while ($true) {
                $password = Read-Host -AsSecureString "Enter the new password for ${username}"
                $confirmPassword = Read-Host -AsSecureString "Confirm the new password for ${username}"

                if ($password.Length -eq 0) {
                    Write-Warning "Password cannot be empty."
                    continue
                }

                $pBSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
                $cpBSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword)

                $pPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($pBSTR)
                $cpPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($cpBSTR)

                if ($pPlainText -ne $cpPlainText) {
                    Write-Warning "Passwords do not match. Please try again."
                    continue
                }

                $passwordString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

                return @{ Secure = $password; Plain = $passwordString }
            }
        }

        Write-Warning "Invalid choice. Please enter 1 or 2."
    }
}

# Function to set the clientadmin password
function Set-ClientAdminPassword {
    Write-Progress-Message "Configuring clientadmin Password" "Magenta"

    $username = "clientadmin"
    # Check if user exists
    try {
        $user = Get-LocalUser -Name $username -ErrorAction Stop
    }
    catch {
    Write-Warning "User ${username} not found. Skipping password change."
        return
    }

    $passwordInfo = Get-ValidPassword -username $username
    if ($null -eq $passwordInfo.Secure) {
    Write-Host "Skipping password change for ${username}." -ForegroundColor Yellow
        return
    }

    try {
        $user | Set-LocalUser -Password $passwordInfo.Secure
        Write-TicketInfoToTempFile -Key "CLIENTADMIN_PASSWORD" -Value $passwordInfo.Plain
    Write-Host "✓ Password for ${username} has been changed successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "✗ Failed to change password for ${username}: $_"
    }
}

# Function to add a new local admin user
function Add-LocalAdminUser {
    Write-Progress-Message "Adding New Local Admin User" "Magenta"

    $choice = Read-Host "Do you want to add another local admin user? (y/n)"
    if ($choice -ne 'y') {
        return
    }

    $username = Read-Host "Enter the username for the new local admin"
    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Warning "Username cannot be empty. Skipping user creation."
        return
    }

    try {
        if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
            Write-Warning "User $username already exists. Skipping user creation."
            return
        }
    }
    catch {}

    $passwordInfo = Get-ValidPassword -username $username
    if ($null -eq $passwordInfo.Secure) {
        Write-Host "Skipping user creation for ${username}." -ForegroundColor Yellow
        return
    }

    try {
        New-LocalUser -Name $username -Password $passwordInfo.Secure -FullName $username -Description "Local administrator account"
        Add-LocalGroupMember -Group "Administrators" -Member $username
    Write-TicketInfoToTempFile -Key "USER_USERNAME" -Value $username
    Write-TicketInfoToTempFile -Key "USER_PASSWORD" -Value $passwordInfo.Plain
    Write-Host "✓ User ${username} created and added to the Administrators group." -ForegroundColor Green
    }
    catch {
        Write-Warning "✗ Failed to create user ${username}: $_"
    }
}

# Call the function to set the clientadmin password
Set-ClientAdminPassword

# Call the function to add a new local admin user
Add-LocalAdminUser

# Function to disable Fast Startup
function Disable-FastStartup {
    Write-Progress-Message "Disabling Fast Startup" "Magenta"
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force
        Write-Host "✓ Fast Startup has been disabled." -ForegroundColor Green
    }
    catch {
        Write-Warning "✗ Failed to disable Fast Startup: $_"
    }
}

# Call the function to disable Fast Startup
Disable-FastStartup

Write-Progress-Message "Endpoint Configuration Process Complete" "Green"
