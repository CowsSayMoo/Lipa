# Lipa Device Setup Script

This PowerShell script automates the setup and configuration of a new Windows 11 device. It handles device naming, user account creation, system settings, software installation, and system updates.

## How to Use

1.  Clone or download the script to the target machine.
2.  Open PowerShell **as an Administrator**.
3.  Navigate to the directory containing the script.
4.  Execute the script by running:
    ```powershell
    .\Lipa_device_setup_script.ps1
    ```
5.  Follow the on-screen prompts. The script will guide you through the configuration process.

Upon completion, the script will generate two files on your Desktop:
*   `lipa_setup_ticket_entry.txt`: A summary of the setup, including device name, credentials, and installed packages.
*   `lipa_setup_error_logs.txt`: A log file that will only be created if errors occurred during the script's execution.

## How to Customize Installed Software

You can easily add or remove software by editing the script.

1.  Open `Lipa_device_setup_script.ps1` in any text editor.
2.  Locate the `$packages` array. It will look like this:

    ```powershell
    # Define base packages to install with their Winget IDs
    $packages = @(
        @{Name="RustDesk"; ID="RustDesk.RustDesk"},
        @{Name="Mozilla Firefox"; ID="Mozilla.Firefox"},
        @{Name="Google Chrome"; ID="Google.Chrome"}
        # ... and so on
    )
    ```

3.  **To add software**, add a new line to this array. You will need the package `Name` and `ID`.
4.  **To find package information**, use the `winget.run` community repository:
    *   **[https://winget.run/](https://winget.run/)**

    For example, to add the VLC media player, you would search for it on `winget.run` and find its ID is `VideoLAN.VLC`. Then, you would add this line to the array:
    `@{Name="VLC media player"; ID="VideoLAN.VLC"}`

5.  **To remove software**, simply delete or comment out the corresponding line from the array.