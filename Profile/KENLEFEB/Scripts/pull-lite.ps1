Function Pull-Lite {
    Push-Location . -StackName 'pull-lite'
    Write-Host -ForegroundColor Green "Pulling [Production]"
    cd "$env:GIT_REPOS\vs.c\mp\LITE\lite\production"
    git pull
    Write-Host -ForegroundColor Green "Pulling [Staging]"
    cd "$env:GIT_REPOS\vs.c\mp\LITE\lite\staging"
    git pull
    Pop-Location -StackName 'pull-lite'
}