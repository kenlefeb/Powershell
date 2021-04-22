[CmdletBinding()]
param (
    [String] $Path = "$env:USERPROFILE\Downloads\Takeout\Google Photos",
    [String] $Output = "$env:USERPROFILE\Pictures",
    [Switch] $WhatIf
)

if (Test-Path $Path) {
    $Path = Get-Item $Path
}

if (Test-Path $Output) {
    $Output = Get-Item $Output
} else {
    $Output = New-Item $Path -WhatIf:$WhatIf
}

Write-Host "Moving Photos..."
Write-Host "From: $Path"
Write-Host "To: $Output"
Write-Host ""

Function Get-NameOfCopy(
    [String] $Path,
    [Int64] $Counter
) {

    if ($Counter -eq 0) {
        return $Path
    }

    $file = Get-Item $Path

    return "$($file.DirectoryName)\$($file.BaseName) #$Counter$($file.Extension)"
}

Function Move-ItemSafely(
    [String] $Path,
    [String] $Destination,
    [Switch] $WhatIf
) {
    $file = Get-Item $Path
    $newDestination = ([System.IO.Path]::Combine($Destination, $file.Name))

    $counter = 0
    $newDestination = Get-NameOfCopy -Path $newDestination -Counter $counter
    
    While (Test-Path "$newDestination") {
        $counter += 1
        $newDestination = Get-NameOfCopy -Path $newDestination -Counter $counter
    }

    Move-Item -Path $Path -Destination $newDestination -WhatIf:$WhatIf
}

Function Move-Photos(
    [String] $Path,
    [String] $Output,
    [Switch] $WhatIf
) {
    if (!(Test-Path $Path)) {
        return #Ignore non-existent paths
    }

    if ($Path -match "@.*") {
        return #Ignore paths under folders beginning with '@' symbol
    }

    if ($Path -match "(?<year>\d{4})\-(?<month>\d{2})\-(?<day>\d{2}).*") {
        $year = $Matches['year']
        $month = $Matches['month']
        $day = $Matches['day']

        $destination = "$Output\$year\$month\$day"

        if (!(Test-Path $destination)) {
            $ignore = New-Item $destination -ItemType Directory
        }

        Write-Host "Moving photos from $Path to $destination"

        foreach($photo in (Get-ChildItem $Path)) {
            Move-ItemSafely -Path $photo -Destination $destination -WhatIf:$WhatIf
        }

        if ((Get-ChildItem $Path).Count -eq 0) {
            Write-Host "Removing empty directory $Path"
            Remove-Item $Path
        }

    } else {
        Write-Host "Skipping $Path"
    }

}

foreach($folder in Get-ChildItem -Path $Path -Directory -Recurse) {
    Move-Photos -Path $folder -Output $Output -WhatIf:$WhatIf
}
