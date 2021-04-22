Write-Host "Loading the GoToFolder feature"

Set-Variable -Scope Global -Name SOURCE -Value "C:\src"

function Edit-GotoFolders(
    [string] $Path = "$PSScriptRoot\..\goto.csv"
) {
    code $Path
}

function Get-GotoFolders(
    [string] $Path = "$PSScriptRoot\..\goto.csv"
) {
    if (!(Test-Path $Path)) {
        Write-Error "Could not find $Path"
        return
    }
    Return Import-Csv($Path)
}

function Reset-FolderList(
    [string] $Path = "$PSScriptRoot\..\goto.csv"
) {
    $global:goto_folderList = Get-GotoFolders $Path
}

function Set-TargetFolder(
    [string]$alias,
    [string]$branch = '-'
) {
    $target = $global:goto_folderList | Where-Object { $_.alias -eq $alias }

    if ($null -eq $target) {
        Write-Error "The alias `"$alias`" was not found in `"goto.csv`"."
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
Set-Alias -Name goto -Value Set-TargetFolder
