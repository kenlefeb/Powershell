Write-Host 'Defining Get-GitIgnore (gig) function'

Function Get-GitIgnore {
    param(
      [Parameter(Mandatory=$true)]
      [string[]]$list
    )
    $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
    Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$params" | select -ExpandProperty content | Out-File -FilePath $(Join-Path -path $pwd -ChildPath ".gitignore") -Encoding ascii
  }

New-Alias -Name gig -Value Get-GitIgnore