Function Pull-Master {
    Push-Location . -StackName 'pull-master'
    Write-Host -ForegroundColor Green "Pulling [Master]"
    cd ..\master
    git pull
    Pop-Location -StackName 'pull-master'
}