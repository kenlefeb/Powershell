# Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme ~\.mytheme.omp.json

Import-Module Git-Worktrees

$autorun = "$PSScriptRoot\AutoRun"

if (!(Test-Path env:PS)) {
    New-Item env:PS -value "$PSScriptRoot\Scripts"
}

Write-Host "Looking in $autorun for scripts to run"

foreach ($script in (Get-ChildItem -Path $autorun *.ps1)) {
    $path = $script.FullName
    Write-Host "Executing '. $path'"
    Invoke-Expression ". $path"
}

