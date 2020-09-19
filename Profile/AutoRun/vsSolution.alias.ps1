# Launch Visual Studio with solution

if (Test-Path function:Start-VisualStudio) {
    Write-Host "Redefining the VS alias"
}
else {
    Write-Host "Defining the VS alias"
}

Function Start-VsDevShell {
    # Incorporate the Visual Studio Developer Shell
    $location = Get-Location

    $root = Get-VisualStudioPath

    if ($null -eq $root) {
        Write-Error "Could not find an installed copy of Visual Studio."
        return
    }

    $script = Get-ChildItem $root -Include 'Launch-VsDevShell.ps1' -Recurse

    if ($null -eq $script) {
        Write-Error "Could not find the Launch-VsDevShell.ps1 script."
        return
    }

    $command = ". `"$($script.FullName)`""

    Invoke-Expression $command

    Set-Location $location
}

Function Get-VisualStudioPath{

    $root = "${env:ProgramFiles(x86)}\Microsoft Visual Studio"

    if (!(Test-Path $root)) {
        Write-Error "Visual Studio is not installed on this machine."
        return
    }

    $versions = (Get-ChildItem $root -Directory | Where-Object -Property Name -Match '\d{4}' | Sort-Object -Property Name -Descending)

    if ($versions.Length -eq 0) {
        Write-Host "There are no versions of Visual Studio installed on this machine."
        return
    }

    $latest = $versions[0]

    $editions = (Get-ChildItem $latest -Directory | Where-Object -Property Name -Match '(Community|Professional|Enterprise|Preview)')

    foreach( $edition in @('Enterprise','Professional','Community','Preview')) {
        $candidate = ($editions | Where-Object -Property Name -eq $edition)
        if ($null -ne $candidate) {
            return $candidate
        }
    }

    return $null

}

Function Start-VisualStudio(
    $Path, 
    [ValidateSet('2017', '2019', 'rider')]$Version,
    [ValidateSet('Professional', 'Enterprise')]$Edition,
    $Developer = 'Ken',
    [switch]$Admin,
    [switch]$WhatIf
) {

    # Default Values based on Computer Name
    switch ($env:COMPUTERNAME) {
        'KENLEFEB' {
            if ($null -eq $Version) {
                $Version = '2019'
            }
            if ($null -eq $Edition) {
                $Edition = 'Professional'
            }
        }
        '7HSMQ13' {
            if ($null -eq $Version) {
                $Version = '2019'
            }
            if ($null -eq $Edition) {
                switch ($Version) {
                    '2017' {
                        $Edition = 'Enterprise'
                    }
                    '2019' {
                        $Edition = 'Professional'
                    }
                }
            }
        }
    }

    $vsRoot = 'C:\Program Files (x86)\Microsoft Visual Studio'
    $jetBrainsRoot = "$env:USERPROFILE\AppData\Local\JetBrains"

    if ($Admin.IsPresent) {
        Write-Host "With administrative privileges"
    }

    if ($Version -eq 'rider') {
        Write-Host "Using JetBrains Rider"
        $devenv = "$jetBrainsRoot\Toolbox\apps\Rider\ch-0\192.6584.65\bin\rider64.exe"
    }
    else {
        Write-Host "Using Microsoft Visual Studio $Version $Edition"
        $devenv = "$vsRoot\$Version\$Edition\Common7\IDE\devenv.exe"
    }

    $file = [System.IO.FileInfo](Get-Solution -Path $Path -Developer $Developer)

    if ($file -ne $null) {
        if (Test-Path $file) {
            $file = "`"$file`""
        }
        else {
            $file = $null
        }
    }

    if ($Admin.IsPresent) {
        if ($WhatIf.IsPresent) {
            if ($null -eq $file) {
                Write-Host "would execute: Start-Process $devenv -Verb runAs"
            }
            else {
                Write-Host "would execute: Start-Process $devenv -ArgumentList $file -Verb runAs"
            }
        }
        else {
            if ($null -eq $file) {
                Start-Process $devenv -Verb runAs
            }
            else {
                Start-Process $devenv -ArgumentList $file -Verb runAs
            }
        }
    }
    else {
        if ($WhatIf.IsPresent) {
            if ($null -eq $file) {
                Write-Host "would execute: Start-Process $devenv"
            }
            else {
                Write-Host "would execute: Start-Process $devenv -ArgumentList $file"
            }
        }
        else {
            if ($null -eq $file) {
                Start-Process $devenv
            }
            else {
                Start-Process $devenv -ArgumentList $file
            }
        }
    }
}

Function Get-CandidateFile(
    [string] $Include
) {
    $files = Get-ChildItem -Include $Include -Recurse | Select-Object -Property Name, Directory, @{ Name = 'DirectoryLength'; Expression = { $_.DirectoryName.Length } } | Sort-Object -Property DirectoryLength | Select-Object -Property @{ Name = 'FullName'; Expression = { "$($_.Directory)\$($_.Name)" } }
    if ($files -is [array] -and $files.Count -gt 0) {
        return $files[0].FullName
    }
    if ($null -ne $files) {
        return $files.FullName
    }
    return $null
}

Function Get-Solution(
    $Path,
    $Developer = 'Ken'
) {
      
    if ($null -eq $Path) {
        Write-Host "No parameter specified; looking for solutions for $Developer"

        $Path = Get-CandidateFile "*.$Developer.sln"

        if ($null -eq $Path) {
            $Path = Get-CandidateFile *.sln
        }

        if ($null -eq $Path) {
            Write-Host "No solution found; looking for projects"
            $Path = Get-CandidateFile "*.csproj"
        }

    } else {

        if ($Path.EndsWith('.sln') -eq $false -and $Path.EndsWith('.csproj') -eq $false) {

            Write-Host "No .sln or .csproj extension specified; looking for solutions"
            if ((Test-Path "$Path.sln") -eq $true) {
                $Path = "$Path.sln"
            }
            else {
                Write-Host "Looking for projects"
                if ((Test-Path "$Path.csproj") -eq $true) {
                    $Path = "$Path.csproj"
                }
            }
        }
    }

    if ($null -eq $Path) {
        Write-Error "Could not find any solution or project to open."
        return
    }
    Write-Host "Found $Path"

    return $Path
}

Set-Alias -name "vs" -value "Start-VisualStudio"

Write-Host "Launching the Visual Studio Developer PowerShell"
. Start-VsDevShell
