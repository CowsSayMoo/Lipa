$packageList = @(
    @{
        Name = "7zip" 
        wingetID = "test.test"
    },
    @{
        Name = "Git"
        wingetID = "Git.git"
    }
)

$indexList = [System.Collections.Generic.List[int]]::new()


foreach ($package in $packageList) {
    $index = $packageList.IndexOf($package)
    winget install --id $package.wingetID --accept-package-agreements --accept-source-agreements --source winget
    Write-Host($LASTEXITCODE)
    
    
}

$indexList


