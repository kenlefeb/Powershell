Write-Host "Defining Set-Color"

Function Set-Color(
    [string] $Path = ".\.vscode\settings.json",
    [ValidateSet('red', 'green', 'blue', 'default')]
    [string] $Color = 'default',
    [Switch] $Force
) {

    $color_code = switch ($Color) {
        "red" { "#ff0000"; break }
        "green" { "#00ff00"; break }
        "blue" { "#0000ff"; break }
        default { $null; break }
    }

    if (!(Test-Path $Path)) {
        if ($Force) {
            '{}' | Out-File $Path -Force
        } else {
            Write-Error "The file $Path does not exist!"
            Return
        }
    }

    $parsed = ((Get-Content $Path) | ConvertFrom-Json)
    $colors = $parsed.'workbench.colorCustomizations'

    if ($null -eq $colors -and $null -ne $color_code) {
        $colors_json = ("{ ""titleBar.activeBackground"": ""$color_code"" }" | ConvertFrom-Json)
        $parsed | Add-Member -NotePropertyName 'workbench.colorCustomizations' -NotePropertyValue $colors_json
    }
    else {
        $titleBar_active = $colors.'titleBar.activeBackground'
        if ($null -eq $titleBar_active) {
            $colors | Add-Member -NotePropertyName 'titleBar.activeBackground' -NotePropertyValue $color_code
        }
        else {
            if ($null -eq $color_code) {
                $colors.PSObject.Properties.Remove('titleBar.activeBackground')
            }
            else {
                $colors.'titleBar.activeBackground' = $color_code
            }
        }
    }

    $parsed | ConvertTo-Json | Out-File $Path -Force

}