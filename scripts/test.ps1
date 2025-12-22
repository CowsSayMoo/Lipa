$packageList = @(
    @{Name = "7zip"; wingetID = "changme"},
    @{Name = "Git"; wingetID = "Git.git"}
)

enum WingetExitCode {
    Success                  = 0                                    # APPINSTALLER_CLI_ERROR_SUCCESS (or already up-to-date)
    InstallerFailed          = -1978335200                          # APPINSTALLER_CLI_ERROR_INSTALLER_FAILED (installer-specific error)
    HashMismatch             = -1978335215                          # APPINSTALLER_CLI_ERROR_INSTALLER_HASH_MISMATCH
}

$indexList = [System.Collections.Generic.List[int]]::new()


foreach ($package in $packageList) {
    $index = $packageList.IndexOf($package)
    winget install --id $package.wingetID --accept-package-agreements --accept-source-agreements --source winget
    
    switch ($LASTEXITCODE) {
        ([WingetExitCode]::Success) {
             write-host("$($package.Name) installed successfully.") 
            }
        [WingetExitCode]::InstallFailed { "$package.Name install failed."; $indexList.Add($index) }
        [WingetExitCode]::HashMismatch { "$package.Name hash mismatch." }
        Default {}
    }
    $LASTEXITCODE
}

$indexList


# winget uninstall --id Git.Git