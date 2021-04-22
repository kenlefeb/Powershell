$profile_directory = (Get-Item $PROFILE).Directory
$source_directory = Get-Location

Set-Location $profile_directory.Parent
Rename-Item $profile_directory.Name "$($profile_directory.Name) (old)" -Force
New-Item $profile_directory.Name -ItemType Junction -Value $source_directory
