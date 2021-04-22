
Function Get-IpInfo {
	Invoke-RestMethod "https://ipinfo.io/json?token=$env:IPINFOTOKEN"
}