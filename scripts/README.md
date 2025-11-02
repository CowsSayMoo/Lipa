# Scripts Directory

This directory contains automation scripts for various tasks.

## Package Installation Script

The `package-installation.ps1` script automates the installation of a predefined list of software packages using a fallback mechanism (winget, Chocolatey, or direct download).

### How to Execute

To execute the script directly from a web source (e.g., a hosted GitHub Gist or a web server), open PowerShell as an administrator and run the following command:

```powershell
irm "https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/package-installation.ps1" | iex
```

**IMPORTANT SECURITY WARNING:**
Executing scripts directly from the internet can be dangerous. Only run scripts from sources you trust completely. Ensure you review the script's content before execution if you are unsure of its origin.

### Local Execution

Alternatively, you can download the `package-installation.ps1` script and execute it locally:

```powershell
# Navigate to the directory where you saved the script
cd C:\path\to\your\scripts\directory

# Execute the script
.\package-installation.ps1
```

### Log Files

The script logs the installation results to the following files:

*   **Success Log:** `C:\temp\successful_installations.log`
*   **Failure Log:** `C:\temp\failed_installations.log`

