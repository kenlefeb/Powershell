Write-Host "Loading the GoToFolder feature"

Set-Variable -Scope Global -Name SOURCE -Value "C:\src"
Set-Variable -Scope Global -Name SOURCE_BNSFL -Value "$SOURCE\TFS"

function Reset-FolderList(
    [string] $Path = "$PSScriptRoot\..\goToFolder.config"
) {

    if (!(Test-Path $Path)) {
        Write-Error "Could not find $Path"
        return
    }
    
    $global:goto_folderList = Import-Csv($Path)
}

function Set-TargetFolder(
    [string]$alias,
    [string]$branch = '-'
) {
    $target = $global:goto_folderList | Where-Object { $_.alias -eq $alias }

    if ($null -eq $target) {
        Write-Error "The alias `"$alias`" was not found in `"goToFolder.config`"."
        return
    }

    $path = $target.folder

    if ($path.Contains('{branch}')) {
        $path = $path.Replace('{branch}', $branch)
    }

    $path = $ExecutionContext.InvokeCommand.ExpandString($path)

    if ((Test-Path $path) -eq $false) {
        Write-Error "The path `"$path`" does not exist."
        return
    }

    Set-Location $path
}

Reset-FolderList
Set-Alias -Name g -Value Set-TargetFolder
