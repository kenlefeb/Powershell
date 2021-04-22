Write-Host 'Defining package.json functions'

Function Get-PackageJson(
    [parameter(Mandatory = $false)][string] $Path,
    [switch] $WhatIf
) {
    
    if ("" -eq $Path) {

        if ($WhatIf) {
            Write-Host "-Path was not specified, so attempting to discover the package.json file"
        }

        $branch = (Get-GitStatus).Branch
        $root = (Get-Worktrees)[$branch]

        $filespec = "$($root)\package.json"

        if (!(Test-Path $filespec)) {
            $filespec = "$($root)\ui\package.json"
        }
    }
    else {
        $filespec = $Path
    }

    If ($WhatIf) {
        Write-Host "Would look for the file `"$filespec`""
        return $filespec
    }
    else {
        if (!(Test-Path $filespec)) {
            Write-Error 'Cannot find the package.json file; please specify using the -Path parameter.'
            return
        }
        else {
            return $filespec
        }
    }
}

Function Get-IisProxy(
    [parameter(Mandatory = $false)][string] $Path,
    [switch] $WhatIf
) {

    $filespec = Get-PackageJson -Path:$Path -WhatIf:$WhatIf

    if ($null -eq $filespec) {
        return
    }

    if ($WhatIf) {
        Write-Host "Would parse $filespec to find current proxy."
    }
    else {
        $package = Get-Content $filespec | ConvertFrom-Json
        return $package.proxy
    }

}

Function Set-IisProxy(
    [System.Uri] $url = 'http://lrariist01/api', # default proxy for Quest
    [parameter(Mandatory = $false)][string] $Path,
    [switch] $WhatIf
) {

    $filespec = Get-PackageJson -Path:$Path -WhatIf:$WhatIf

    if ($null -eq $filespec) {
        return
    }

    if ($WhatIf) {
        Write-Host "Would parse $filespec to find current proxy and change it to $url"
    }
    else {
        $package = Get-Content $filespec | ConvertFrom-Json

        $before = [System.Uri]$package.proxy
    
        if ($before -eq $url) {
            Write-Warning "The specified URL ($url) is already the current proxy ($before)"
            return
        }
    
        $package.proxy = $url
    
        Write-Host "Updating the package.json file to change the proxy from $before to $url"
    
        ConvertTo-Json $package | Out-File $filespec -Force -Encoding ASCII
    }
}

Function Reset-PackageJson(
    [parameter(Mandatory = $false)][string] $Path,
    [switch] $WhatIf
) {

    $filespec = Get-PackageJson -Path:$Path -WhatIf:$WhatIf

    if ($null -eq $filespec) {
        return
    }

    $command = "git checkout master $filespec"

    if ($WhatIf) {
        Write-Host "Would execute the following command:"
        Write-Host "    $command"
        Write-Host
    }
    else {
        Invoke-Expression $command
    }
}