# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script needs to be run with Administrator privileges. Attempting to re-launch..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -File `"$($myInvocation.MyCommand.Path)`""
    Exit
}

# main.ps1

# Function to display ASCII art
function Show-AsciiArt {
    Write-Host @"
 ___       ___  ________  ________     
|\  \     |\  \|\   __  \|\   __  \    
\ \  \    \ \  \ \  \|\  \ \  \|\  \   
 \ \  \    \ \  \ \   ____\ \   __  \  
  \ \  \____\ \  \ \  \___|\ \  \ \  \ 
   \ \_______\ \__\ \__\    \ \__\ \__\
    \|_______|\|__|\|__|     \|__|\|__|
                                       
                                       
                                       
"@ -ForegroundColor Green
}

# Function to display the menu
function Show-Menu {
    Write-Host "`nSelect a script to run:" -ForegroundColor Yellow
    Write-Host "1. Package Installation Script"
    Write-Host "2. Endpoint Configuration Script"
    Write-Host "3. Autotask Ticket Entry Generation Script"
    Write-Host "4. Exit"
    Write-Host "`nEnter your choice (1-4): " -NoNewline
}

# Main loop
while ($true) {
    Show-AsciiArt
    Show-Menu

    $choice = Read-Host

    switch ($choice) {
        "1" {
            Write-Host "Running Package Installation Script..." -ForegroundColor Cyan
            Invoke-Restmethod "https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/package-installation.ps1" | Invoke-Expression
            Read-Host "Press Enter to continue..."
        }
        "2" {
            Write-Host "Running Endpoint Configuration Script..." -ForegroundColor Cyan
            Invoke-Restmethod "https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/endpoint-configuration.ps1" | Invoke-Expression
            Read-Host "Press Enter to continue..."
        }
        "3" {
            Write-Host "Running Autotask Ticket Entry Generation Script..." -ForegroundColor Cyan
            Invoke-Restmethod "https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/generate-ticket.ps1" | Invoke-Expression
            Read-Host "Press Enter to continue..."
        }
        "4" {
            Write-Host "Exiting..." -ForegroundColor Red
            break
        }
        default {
            Write-Host "Invalid choice. Please enter a number between 1 and 4." -ForegroundColor Red
            Read-Host "Press Enter to continue..."
        }
    }
    Clear-Host
}
