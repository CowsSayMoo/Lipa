# Scripts Directory Overview

This directory serves as a knowledge base for LIPA support engineers, containing automation scripts to streamline common support tasks and endpoint configurations.

## Key Files:

*   **`README.md`**: Provides an overview of the scripts directory, including descriptions and execution instructions for the PowerShell scripts.
*   **`endpoint-configuration.ps1`**: A PowerShell script designed to automate various endpoint configuration and system maintenance tasks. This includes setting device names, managing local user passwords (specifically for 'clientadmin'), adding new local admin users, disabling Fast Startup, configuring Outlook to classic mode, and moving the Splashtop executable.
*   **`package-installation.ps1`**: A PowerShell script that automates the installation of a predefined list of software packages. It utilizes a fallback mechanism, attempting installation via Winget first, then Chocolatey, and finally opening a direct download URL if other methods fail. It also handles Chocolatey installation if not already present and logs installation results.

## Usage:

The scripts in this directory are intended to be executed in a PowerShell environment, typically with administrator privileges. The `README.md` provides specific instructions for executing each script, often involving direct execution from a web source.

These scripts are crucial for:
*   **Automating Endpoint Configuration:** Ensuring new and existing machines adhere to LIPA's standards.
*   **Streamlining Software Deployment:** Efficiently installing necessary software packages on endpoints.
*   **Standardizing Support Procedures:** Providing out-of-the-box solutions for common customer setups.