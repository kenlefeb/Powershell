if (Test-Path Function:\New-GitIgnore) {
    Write-Host 'Redefining the New-GitIgnore function'
    Remove-Item Function:\New-GitIgnore
} else {
    Write-Host 'Defining the New-GitIgnore function'
}

Function New-GitIgnore {

[CmdletBinding()]
Param (
    [string] $Project = 'VisualStudio'
)

    $list = ($Project | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
    $output = $(Join-Path -path $pwd -ChildPath ".gitignore")

    Write-Debug "Projects: $list"
    Write-Debug ""

    Invoke-WebRequest -Uri "https://www.gitignore.io/api/$list" | select -ExpandProperty content | Out-File -FilePath $output -Encoding ascii

    Write-Host "Created '$output'."
}
