#Start-Process -Verb RunAs pwsh.exe -Args "-executionpolicy bypass -command Set-Location \`"$PWD\`"; $args"
Write-Host "Defining sudo function"
function sudo()
{
    start-process pwsh.exe -ArgumentList $args[0..$args.Length] -verb "runAs" -NoNewWindow
}