# Lipa Device Setup Script

A PowerShell script to automate the initial setup and configuration of Windows devices.

## Features

- **Device Name Configuration** - Change computer name
- **Software Installation** - Automatically installs:
  - RustDesk
  - Mozilla Firefox
  - Google Chrome
  - Foxit PDF Reader
  - Adobe Acrobat Reader
  - HP Image Assistant
- **System Configuration**
  - Disables Fast Startup
  - Configures ClientAdmin account password
  - Creates new local administrator users
- **Updates & Drivers**
  - Installs all available Windows Updates
  - Runs HP Image Assistant for driver updates (HP devices)

## Quick Start

Run this command in PowerShell as Administrator:

```powershell
irm "https://raw.githubusercontent.com/CowsSayMoo/Lipa/main/Lipa_device_setup_script.ps1" | iex
```

## Prerequisites

- Windows 10 (version 1809+) or Windows 11
- Administrator privileges
- Winget (Windows Package Manager) - built into modern Windows

## Script Workflow

The script will prompt you through the following steps:

1. **Change Device Name** (Optional)
2. **Install Software Packages** - Automatically installs all listed applications
3. **Disable Fast Startup** - Improves dual-boot compatibility and ensures clean shutdowns
4. **Configure ClientAdmin Account** (Optional)
5. **Create New Local User** (Optional)
6. **Install Windows Updates** (Optional) - May take significant time depending on update size
7. **Run HP Image Assistant** (Optional) - Only available on HP devices
8. **Restart Prompt** - Offers to restart if changes require it

## Notes

- The script requires Administrator privileges to run
- Software installation uses the default Winget repository
- HP Image Assistant path: `C:\SWSetup\HPImageAssistant\HPImageAssistant.exe`
- Some operations may take several minutes to complete
- A restart may be required after completion

## Troubleshooting

**"HP Image Assistant not found"**
- Ensure HP Image Assistant installed correctly
- Check if file exists at: `C:\SWSetup\HPImageAssistant\HPImageAssistant.exe`

**"Package not found"**
- Ensure internet connection is active
- Winget may need to update its package list

**Windows Updates failing**
- PSWindowsUpdate module will be installed automatically
- If issues persist, use Windows Settings to update manually

## License

Free to use and modify as needed.
