
if (Test-Path function:Set-LocationToday) {
    Write-Host "Redefining the Today alias"
} else {
    Write-Host "Defining the Today alias"
}

if (Test-Path function:Set-LocationNow) {
    Write-Host "Redefining the Now alias"
} else {
    Write-Host "Defining the Now alias"
}

Function Set-LocationForSure(
    [string] $Path
) {

    if ((Test-Path $path) -eq $false) {
        $ignore = (New-Item -ItemType Directory -Path $path)
    }

    if ((Test-Path $path) -eq $false) {
        Write-Error "An error occurred attempting to create the path ""$path""."
    } else {
        Set-Location $path
    }
}

Function Set-LocationToday(
    [DateTime] $Date
){

    if ($Date -eq $null) {
        $Date = Get-Date
    }

    $Path = "$env:USERPROFILE\OneDrive\Desktop\$($Date.ToString('yyyy\\MM\\dd'))"
    Set-LocationForSure -Path $Path
    Set-EnvironmentVariable -Name 'Today' -Value $Path -Scope 'User'
}

Function Set-LocationNow(
    [DateTime] $Date
){

    if ($Date -eq $null) {
        $Date = Get-Date
    }

    $Path = "$env:USERPROFILE\OneDrive\Desktop\$($Date.ToString('yyyy\\MM\\dd\\HH'))"
    Set-LocationForSure -Path $Path
    Set-EnvironmentVariable -Name 'Now' -Value $Path -Scope 'User'
}

Function Set-EnvironmentVariable(
    [string] $Name,
    [string] $Value,
    [string][ValidateSet('Process','User','Machine')] $Scope = 'Process'
) {
    Write-Host "Setting the $Scope environment variable `"$Name`" to `"$Value`"."
    [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
}

Set-Alias -name "today" -value "Set-LocationToday"
Set-Alias -name "now" -value "Set-LocationNow"

if ($args[0] -eq "today") {
    Set-LocationToday
}