Write-Host 'Defining Get-PackageInfo function'

class Package
{
    [String]$id
    [String]$version
    [String]$targetFramework
    [String]$path
}

function Get-PackageInfo([string]$path) {
    $packages = @()
    [xml]$XmlDocument = Get-Content -Path $path
    Foreach($p in $XmlDocument.Packages.package) {
        $pak = New-Object Package
        $pak.id = $p.id
        $pak.version = $p.version
        $pak.targetFramework = $p.targetFramework
        $pak.path = $path
        $packages += $pak 
    }
    return $packages 
}

Write-Host 'Defining Get-ProjectFiles function'

function Get-ProjectFiles ([string]$sourceFolder)
{   
    $allPackages = @()
    $filesToWorkWith = gci $sourceFolder -recurse -filter "packages.config" -file -ErrorAction SilentlyContinue 
    ForEach ($file in $filesToWorkWith)
    {
       $allPackages += $packages = Get-PackageInfo($file.FullName);
    }

    return $allPackages
}

Write-Host 'Defining Get-NugetConsolidations function'

function Get-NugetConsolidations ([string]$sourceFolder)
{
    $allresults = Get-ProjectFiles($sourceFolder)

    return $allresults | group -p id |
    where { $_.count -ge 2 } | % { $_.Group } | 
    sort -u id, version | 
    group -p id |
    where { $_.count -ge 2 } | % { $_.Group } | 
    sort -u id, version
}

Write-Host 'Defining Test-ProjectExists function'

function Test-ProjectExists ([string]$sourceFolder, [string]$filter)
{
    $allresults = Get-ProjectFiles($sourceFolder)

    return $allresults | where {$_.id -Like $filter}
}
