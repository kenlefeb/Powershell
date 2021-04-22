Write-Host "Setting environment variables..."
New-Item env:IPINFOTOKEN -value "077f3a9f8bfb79" -Force
New-Item env:SOURCE -value "C:\src" -Force
New-Item env:SOURCE_BNSFL -value "$env:SOURCE\TFS" -Force
New-Item env:HOMEDRIVE -value C: -Force
New-Item env:HOMEPATH -value \Users\kenneth.lefebvre -Force
New-Item env:HOME -value C:\Users\kenneth.lefebvre -Force
