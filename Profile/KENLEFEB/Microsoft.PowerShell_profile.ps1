Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox

Import-Module Git-Worktrees

$autorun = "$PSScriptRoot\AutoRun"
New-Item env:PS -value "$PSScriptRoot\Scripts"

Write-Host "Looking in $autorun for scripts to run"

Get-ChildItem -Path $autorun *.ps1 | ForEach-Object { Write-Host "Executing '. $_'" ; Invoke-Expression ". $_" }
