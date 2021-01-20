Write-Host "Defining Execute Process functions"

# NOTE: This is an unfinished script

Function Get-Role() {

    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = new-object System.Security.Principal.WindowsPrincipal $id
    $administrator = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    if ($principal.IsInRole($administrator)) {
        Write-Output 'Administrator'
    } else {
        Write-Output 'User'
    }

}

Function Start-Command(
    [String] $Command,
    [String] $Title,
    [Switch] $Admin
) {

    $startInfo = new-object System.Diagnostics.ProcessStartInfo $Title
    $startInfo.Arguments = $Command

    if ($Admin) {
    $startInfo.Verb = 'runas'
    }

    [System.Diagnostics.Process]::Start($startInfo)
}