# Windows System Setup Script

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

## Prerequisites

- Windows 10 (version 1809+) or Windows 11
- Administrator privileges
- Winget (Windows Package Manager) - built into modern Windows

## How to Use

### Method 1: Run with Bypass (Recommended)

1. Download the script to your device
2. Right-click **PowerShell** and select **"Run as Administrator"**
3. Navigate to the script location:
   ```powershell
   cd C:\path\to\script
   ```
4. Run with execution policy bypass:
   ```powershell
   PowerShell -ExecutionPolicy Bypass -File ".\install-software.ps1"
   ```

### Method 2: Unblock the File

1. Right-click the `.ps1` file
2. Select **Properties**
3. Check **"Unblock"** at the bottom
4. Click **OK**
5. Right-click **PowerShell** and select **"Run as Administrator"**
6. Run the script:
   ```powershell
   .\install-software.ps1
   ```

### Method 3: Set Execution Policy (Current User Only)

1. Right-click **PowerShell** and select **"Run as Administrator"**
2. Run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Type `Y` and press Enter
4. Run the script:
   ```powershell
   .\install-software.ps1
   ```

## Script Workflow

The script will prompt you through the following steps:

1. **Change Device Name** (Optional)
   - Enter new computer name or skip

2. **Install Software Packages**
   - Automatically installs all listed applications

3. **Disable Fast Startup**
   - Improves dual-boot compatibility and ensures clean shutdowns

4. **Configure ClientAdmin Account** (Optional)
   - Set password for existing ClientAdmin account

5. **Create New Local User** (Optional)
   - Create a new administrator account with custom credentials

6. **Install Windows Updates** (Optional)
   - Scans and installs all available Windows updates
   - May take significant time depending on update size

7. **Run HP Image Assistant** (Optional)
   - Launches HPIA for HP driver updates
   - Only available on HP devices

8. **Restart Prompt**
   - Offers to restart if changes require it

## Notes

- The script requires Administrator privileges to run
- Software installation uses the default Winget repository
- HP Image Assistant path: `C:\SWSetup\HPImageAssistant\HPImageAssistant.exe`
- Some operations may take several minutes to complete
- A restart may be required after completion

## Troubleshooting

**"Scripts are disabled on this system"**
- Use Method 1 (Bypass) or Method 2 (Unblock) above

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
