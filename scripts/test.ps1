$PackageList = @(
    @{ Name = "Rustdesk"; WingetId = "RustDesk.RustDesk"; chocoId = "rustdesk" },
    @{ Name = "Firefox"; WingetId = "Mozilla.Firefox"; chocoId = "firefox" },
    @{ Name = "Google Chrome"; WingetId = "Google.Chrome"; chocoId = "googlechrome" },
    @{ Name = "Adobe Acrobat Reader"; WingetId = "Adobe.Acrobat.Reader.64-bit"; chocoId = "adobereader" },
    @{ Name = "Foxit PDF Reader"; WingetId = "XPFCG5NRKXQPKT"; chocoId = "foxitreader" },
    @{ Name = "Belgian EID middleware"; WingetId = "BelgianGovernment.eIDmiddleware"; chocoId = "belgian-eid-middleware" },
    @{ Name = "Belgian EID viewer"; WingetId = "BelgianGovernment.eIDViewer"; chocoId = "belgian-eid-viewer" },
    @{ Name = "OpenVPN Connect"; WingetId = "OpenVPNTechnologies.OpenVPNConnect"; chocoId = "openvpn-connect" },
    @{ Name = "VLC Media player"; WingetId = "VideoLAN.VLC"; chocoId = "vlc" },
    @{ Name = "MS Office 365 Apps"; WingetId = "Microsoft.Office"; chocoId = "office365proplus" }
)

enum WingetExitCode {
    Success = 0           
    InstallerFailed = -1978335200
    HashMismatch = -1978335215   
}

$indexList = [System.Collections.Generic.List[int]]::new()

foreach ($package in $PackageList) {
    $index = $PackageList.IndexOf($package)
    $installed = winget list --id $package.WingetId --exact | Out-String | Should -Not -Match "$($package.Name) - $($package.Version)"
    
    if (-not $installed) {
        winget install --id $($package.WingetId) --accept-package-agreements --accept-source-agreements --source winget
        switch ($LASTEXITCODE) {
            ([WingetExitCode]::Success) { 
                write-host("$($package.Name) installed successfully.") 
            }
            ([WingetExitCode]::InstallerFailed) { 
                write-host("$($package.Name) install failed."); $indexList.Add($index) 
            }
            ([WingetExitCode]::HashMismatch) { 
                write-host("$($package.Name) hash mismatch."); $indexList.Add($index) 
            }
            Default { 
                write-host("$($package.Name) install failed."); $indexList.Add($index) 
            }
        }
    }
}

$indexList