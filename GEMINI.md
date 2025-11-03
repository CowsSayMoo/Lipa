# Lipa Support Engineer Knowledge Base

## Directory Overview

This repository is a knowledge base for a support engineer at LIPA. It contains best practices, learnings, and automation scripts to assist with common customer issues and streamline support tasks. The focus is on providing out-of-the-box solutions for customers and automating endpoint configuration and maintenance.

## Key Areas

### Customer Configurations

This section will contain guides and configurations for common customer setups. The goal is to have pre-configured solutions that work "out of the box" for new customers.

### Automation Scripts

The `scripts` directory will house automation scripts for tasks such as:

*   Endpoint configuration
*   System maintenance
*   Automated troubleshooting

### Troubleshooting Guides

The `Guides` directory will contain troubleshooting guides for common user issues, including:

*   Printing problems
*   Networking issues
*   Common tasks in Windows and macOS

## Usage

This repository is intended to be a living document, updated with new learnings and best practices as they are developed. The guides and scripts should be organized and well-documented to be easily accessible during customer interactions.

---

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