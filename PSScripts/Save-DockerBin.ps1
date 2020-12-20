# See https://developer.github.com/v3/repos/releases/#get-the-latest-release
$latest = Invoke-RestMethod -Uri "https://api.github.com/repos/docker/docker/releases/latest" -Method Get

if ($latest.body | where { $_ -match "https://get.docker.com/builds/Windows/x86_64/.*.zip" }) {
	$uri = $Matches[0]
	$outFile = Join-Path $DOWNLOADS (Split-Path $uri -Leaf)
	Invoke-WebRequest $uri -OutFile $outFile -Verbose

	$md5 = (Get-FileHash $outFile -Algorithm MD5).Hash
	$md5expected = (Invoke-WebRequest "${uri}.md5").Content.Split(" ")[0]
	Write-Verbose "Checking MD5 checksum"
	Write-Verbose "Expected: $md5expected"
	if ($md5 -eq $md5expected) {
		Write-Host "MD5 checksums are the same"
	} else {
		Write-Host "Unexpected MD5 checksum: $md5" -ForegroundColor Red
		return
	}

	Expand-Archive $outFile -DestinationPath $DOWNLOADS -Verbose
	Move-Item $DOWNLOADS\docker\docker.exe $SCRIPTS

	Remove-Item $DOWNLOADS\docker -Recurse
	Remove-Item $outFile
}
