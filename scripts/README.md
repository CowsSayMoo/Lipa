# Scripts Directory

This directory contains automation scripts for various tasks.

## Package Installation Script

The `package-installation.ps1` script automates the installation of a predefined list of software packages using a fallback mechanism (winget, Chocolatey, or direct download).

### How to Execute

To execute the script directly from a web source (e.g., a hosted GitHub Gist or a web server), open PowerShell as an administrator and run the following command:

```powershell
irm "https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/package-installation.ps1" | iex
```

### Log Files

The script logs the installation results to the following files:

*   **Success Log:** `C:\temp\successful_installations.log`
*   **Failure Log:** `C:\temp\failed_installations.log`

## Endpoint Configuration Script

The `endpoint-configuration.ps1` script is designed to automate various endpoint configuration and system maintenance tasks, ensuring machines adhere to LIPA's standards.

```powershell
irm "https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/endpoint-configuration.ps1" | iex
```

## Autotask Ticket Entry Generation Script

This PowerShell script is designed to automate the creation of support tickets. It streamlines the process of logging new issues, ensuring consistency and reducing manual entry errors. Further details on its parameters and specific usage can be found within the script file itself.

**Execution:**
```powershell
irm "https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/generate-ticket.ps1" | iex
```