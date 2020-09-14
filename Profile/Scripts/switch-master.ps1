Write-Host "Loading Switch-Branch function"
Function Switch-Branch (
    [string] $name = 'master'
) {
    if ($name -eq 'master') {
        $path = Get-Location
    
        if ($path -match '.*\\lite|LITE\\.*') {
            $name = 'Production'
        }

        Write-Output "Switching to $name"
    }
    
    while ($true) {
    
        $path = Get-Location
    
        if ($path -eq "$env:GIT_REPOS") {
            break
        }
    
        if ($path -eq $name) {
            break
        }
    
        if (Test-Path '.\.git' -PathType Container) {
            break
        }
    
        if (Test-Path ".\$name" -PathType Container) {
            Set-Location ".\$name"
            break
        }
    
        Set-Location ..
        
    }
    
}

