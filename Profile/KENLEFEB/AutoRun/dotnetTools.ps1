Write-Host "Defining dotnet utility functions"

Function Reset-BuildOutputs() {
    Get-ChildItem -Include bin,obj -Directory -Recurse | Remove-Item -Recurse
}

Function Get-Package (
    [string] $Path = ".",
    [switch] $Recurse,
    [switch] $Detailed
) {

    $filespec = "*.nupkg"

    $files = Get-ChildItem -Path $Path -Include $filespec -Recurse:$Recurse 
    $packages = $files | Select-Object -Property @{Name = 'Name'; Expression = { $_.BaseName -replace '(.*?)\.\d+\.\d+\.\d+(-.*)?','$1' } } , @{Name = 'Version'; Expression = { $_.BaseName -replace '.*?\.(\d+\.\d+\.\d+(-.*)?)','$1' } }, FullName 

    if (!($Detailed)) {
        $packages = $packages | Select-Object -Property Name,Version
    }

    $packages | Sort-Object -Property Version -Descending | Sort-Object -Property Name

}

<#
        .Synopsis
        Publishes a Nuget package to a package feed.

       .Description
       The Publish-Package function will issue the correct `dotnet nuget push` command to publish the specified package to the specified feed.

       .Parameter Path
       The -Path parameter determines where the search for your package begins. If you do not specify this, we will look in the current location (e.g., `.`).

       .Parameter Name
       The -Name parameter narrows the search for a package to publish. A typical package uses the following naming convention, so this parameter will limit our search to packages where the Name property equals the value in this parameter. If this parameter is not specified, we will search for *.nupkg.

       Naming convention:
           
            Package.Name.1.2.3-label.nupkg

        which parses to the following components:

            Name:       Package.Name
            Version:    1.2.3-label

        .Parameter Recurse
        The -Recurse parameter is a switch that determines whether to search recursively through sub-directories, or limit our search to the -Path parameter. By default, this is True.

        .Parameter Version
        The -Version parameter narrows the search for a package to publish. Using the same naming convention documented in the -Name parameter, this parameter is compared to the Version component of all packages discovered using a "Starts With" comparison. Alternatively, you may also specify the string "latest" to publish whichever version is the highest (by Semantic Versioning rules). If you do not specify a -Version parameter, "Latest" will be used by default.

        .Parameter Source
        The -Source parameter is used to specify where we should publish the discovered package. If you do not specify a source, the local Nuget cache (%USERPROFILE%\.nuget\packages) will be used.

        .Parameter WhatIf
        The -WhatIf parameter is a switch that determines whether to actually perform the publishing or simply to report to the console, what action _would_ have been taken.

        .Example 
        Publish-Package -Name BNSFL.BPM.Client -Version latest

        Publishes the latest version of the BPM Client to the local Nuget cache
#>
Function Publish-Package (
    [string] $Path = ".",
    [string] $Name,
    [switch] $Recurse = $True,
    [string] $Version = "latest",
    [string] $Source = "$env:USERPROFILE\.nuget\packages",
    [string] $ApiKey,
    [switch] $WhatIf = $WhatIfPreference
)
{

    $packages = Get-Package -Path $Path -Recurse:$Recurse -Detailed

    if ($packages.Length -eq 0) {
        Write-Error "Could not find any packages meeting the specified parameters"
        return
    }

    if ($null -ne $Name -and "" -ne $Name) {
        $packages = $packages | Where-Object -Property Name -eq $Name
    }

    if ($packages -is [Array]) {
        $latest = ( $packages | Sort-Object -Property Version -Descending )[0]
    } else {
        $latest = $packages
    }

    if ($Version -eq "latest") {
        $selected = $latest
    } else {
        $selected = ( $packages | Where-Object -Property Version -like "$Version*" )

        if ($selected -is [Array]) {
            $selected = $selected[0]
        }
    }

    if ("" -eq $selected -or $null -eq $selected) {
        Write-Error "Could not find any packages meeting the specified parameters"
        return
    }

    $filespec = $selected.FullName

    if (!(Test-Path $filespec)) {
        Write-Error "The specified package could not be found:"
        $filespec
        return
    }

    if ($Source -eq "$env:USERPROFILE\.nuget\packages") {
        $Feed = @{ Name = "Local Cache"; Uri = $Source ; State = "Enabled" }
    } else {
        $sources = Get-Sources

        if ($sources.ContainsKey($Source)) {
            $Feed = $sources[$Source]
        } else {
            $Feed = @{ Name = "Custom Feed" ; Uri = $Feed ; State = "Enabled" }
        }
    }

    $uri = $Feed.Uri

    if ("" -ne "$ApiKey") {
        $setApiKey = "-k $ApiKey"
    } else {
        if ($uri -like 'http*/tfs/*') {
            $setApiKey = "-k TFS "
        } else {
            $setApiKey = ""
        }
    }

    if ($Feed.Name -eq 'Local Cache') {
        $setSource = "-s $uri"
    } else {
        $setSource = "-s $uri $setApiKey"
    }
    
    $command = "dotnet nuget push `"$filespec`" $setSource --interactive --skip-duplicate"

    if ($WhatIf) {
        Write-Host "Would invoke the following command:"
        Write-Host "    $command"
    } else {
        Invoke-Expression $command
    }
}

Function Get-Sources
{
    $sources = @{};

    (dotnet nuget list source) | ForEach-Object {
        if ($_ -match '^\s+\d+\.\s+(?<Name>.*?)\[(?<State>.*?)\].*$') {
            $name = $($matches.Name).Trim()
            $state = $matches.State
            $sources[$name] = $state
        }
        if ($_ -match '^\s+(?<Uri>[^\[]+)$') {
            $sources[$name] = @{ Name = $name ; Uri = $matches.Uri ; State = $state }
        }
     }

    $sources
}

#For PowerShell v3
Function New-GitIgnore(
    [Parameter(Mandatory = $true)]
    [string[]]$list
) {
    $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
    Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$params" | select -ExpandProperty content | Out-File -FilePath $(Join-Path -path $pwd -ChildPath ".gitignore") -Encoding ascii
}