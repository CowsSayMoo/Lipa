# Lipa Support Engineer Knowledge Base

Welcome to the Lipa Support Engineer Knowledge Base! This repository is a collection of best practices, learnings, and automation scripts to help streamline the work of support engineers at LIPA.

## Goal

The primary goal of this repository is to assemble and configure solutions that work out-of-the-box for our customers. We also aim to automate common processes like endpoint configuration and maintenance to improve efficiency and reduce manual errors.

## Contents

This repository is organized into the following key areas:

*   **Customer Configurations:** This section contains pre-configured setups and guides for various customer environments. The aim is to provide solutions that can be deployed with minimal effort.

*   **Automation Scripts:** The `scripts` directory contains a collection of scripts to automate repetitive tasks. This includes endpoint configuration, system maintenance, and automated troubleshooting.

*   **Troubleshooting Guides:** The `Guides` directory is a collection of step-by-step guides to troubleshoot common user issues. This includes everything from printing and networking problems to common tasks in Windows and macOS.

## Usage

This knowledge base is a living project. All support engineers are encouraged to contribute their learnings and best practices. When you solve a new problem or find a better way to do something, document it here!

Before adding new content, please check if a similar solution already exists. If it does, consider improving the existing document instead of creating a new one.

## Script Usage

### `generate-ticket.ps1`

This PowerShell script is designed to automate the creation of support tickets. It streamlines the process of logging new issues, ensuring consistency and reducing manual entry errors. Further details on its parameters and specific usage can be found within the script file itself.

**Execution:**
```powershell
irm "https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/generate-ticket.ps1" | iex
```
