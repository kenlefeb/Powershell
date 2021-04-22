if (Test-Path Function:\New-DotEnv) {
    Write-Host 'Redefining the New-DotEnv function'
    Remove-Item Function:\New-DotEnv
} else {
    Write-Host 'Defining the New-DotEnv function'
}

Function New-DotEnv {

[CmdletBinding()]
Param (
    [string] $Id = 'BNSFL.Quest',
    [string] $Environment = $null
)

    Write-Debug "Environment: $Environment"
    Write-Debug "ID: $Id"
    Write-Debug ""

    if ([System.String]::IsNullOrEmpty($Environment)) {
        $filename = '.env.local'
    } else {
        $filename = ".env.$Environment.local"
    }

    dotnet user-secrets list --id $Id | Out-File -FilePath $filename

    Write-Host "Created '$filename' with the secrets for '$Id'."
}
