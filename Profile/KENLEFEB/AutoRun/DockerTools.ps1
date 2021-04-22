Write-Host 'Defining Docker-related Functions'

Function Get-DockerIpAddress(
    [string]$Name
) {

    $container = (docker inspect $Name | ConvertFrom-Json)

    if ($null -eq $container) {
        Write-Error "Unable to inspect a Docker container named $Name"
        return
    }

    return $container.NetworkSettings.Networks.nat.IPAddress
}