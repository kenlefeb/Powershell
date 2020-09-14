## Docker Aliases

function dockerGetIP($container) {
    docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container
}
Set-Alias -name "dockerIP" -value "dockerGetIP"

function dockerGetName($container) {
    docker inspect --format='{{.Config.Image}}' $container
}
Set-Alias -name "dockerName" -value "dockerGetName"

function dockerGetPorts($container) {
    docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} -> {{(index $conf 0).HostPort}} {{end}}' $container
}
Set-Alias -name "dockerPorts" -value "dockerGetPorts"

function dockerBrowseIP($container) {
    $ip = docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} -> {{(index $conf 0).HostPort}} {{end}}' $container
    Start-Process "http://$ip"
}
Set-Alias -name "dockerBrowse" -value "dockerBrowseIP"
