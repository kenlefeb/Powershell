if (Test-Path Function:Get-MyCommits) {
	Write-Host 'Removing existing Get-MyCommits function'
	Remove-Item Function:Get-MyCommits
}

Write-Host 'Defining Get-MyCommits function'
Function Get-MyCommits {

Param (
	[Nullable[DateTime]] $Since = $null,
    [string] $Author = $null,
    [string] $Log = $null
)

	$currentLocation = Get-Location

	if ($null -eq $Since) {
		if ((Get-Date).DayOfWeek -eq "Monday") {
			$Since = (Get-Date).AddDays(-3)
		} else {
			$Since = (Get-Date).AddDays(-1)
		}
		$Since = Get-Date $(Get-Date $Since -Format 'yyy-MM-dd')
	}

	if ($null -eq $Author -or "" -eq $Author) {
		$Author = (git config --get user.name)
	}

	if ($null -eq $env:Today) {
		$Path = "."
	} else {
		$Path = $env:Today
	}

	if ($null -eq $Log -or "" -eq $Log) {
		$Log = "$Path\$(Get-Date $Since -Format 'yyyy-MM-dd').git.log"
	}

	Write-Host "Writing to file $Log for $Author since $Since"

	Get-ChildItem -Attributes directory+hidden -Recurse '.git' `
	| ForEach-Object { 
			Write-Host $_.FullName
			Set-Location $_
			git log --author="$Author" --since="$(Get-Date $Since -Format 'yyyy-MM-dd')" --until='now' --all --format='%Cgreen%ci%Creset %s%Creset' --no-merges
		} `
	| Tee-Object $Log

	Set-Location $currentLocation
}
