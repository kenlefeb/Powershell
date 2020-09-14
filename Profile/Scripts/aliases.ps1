#######################################
#         PowerShell Aliases
# Sometimes Powershell can't run commands unless they're wrapped in a function
# http://stackoverflow.com/questions/38981044/the-term-is-not-recognized-as-cmdlet-function-script-file-or-operable-program
#######################################

# ..
Set-Alias -name ".." -value "cd.."

# e.
function explorerHere() {
    Start-Process -FilePath explorer.exe -argumentlist .
}
Set-Alias -name "e." -value "explorerHere"

# npmls
function listNpmGlobalModules() {
    npm ls -g --depth=0
}
Set-Alias -name "npmls" -value "listNpmGlobalModules"

# c
function goToCode() {
    cd ~\Code
}
Set-Alias -name "c" -value "goToCode"

# update
function chocoUpgrade() {
    choco upgrade all
}
Set-Alias -name "update" -value "chocoUpgrade"

# ls
Set-Alias ls Get-ChildItem-Color -option AllScope -Force

# status
function gitStatus($Path) {
    git status
}
Set-Alias -name "status" -value "gitStatus"

# chocolist 
function chocoListLocal() {
    choco list --local-only
}
Set-Alias -name "chocolist" -value "chocoListLocal"

# docker sql-integration
function switchToIntegration() {
    docker stop sql-development
    docker start sql-integration
}
Set-Alias -name "sql-int" -value "switchToIntegration"

# docker sql-development
function switchToDevelopment() {
    docker stop sql-integration
    docker start sql-development
}
Set-Alias -name "sql-dev" -value "switchToDevelopment"

# git pull Production for LITE
function litePullProduction() {
    pushd ..\..\Production ; git pull ; popd
}
Set-Alias -name "pull-prod" -value "litePullProduction"

# git pull Integration for LITE
function litePullIntegration() {
    pushd ..\..\Integration ; git pull ; popd
}
Set-Alias -name "pull-int" -value "litePullIntegration"
