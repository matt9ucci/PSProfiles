function Save-PwshBinary {
	param (
		[string]
		$Tag,

		[Alias('Architecture')]
		[ValidateSet('arm32', 'arm64', 'x64', 'x86')]
		[string]
		$ProcessorArchitecture = 'x64'
	)

	$uri = if ($Tag) {
		"https://api.github.com/repos/PowerShell/PowerShell/releases/tags/$Tag"
	} else {
		'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
	}

	$response = Invoke-RestMethod $uri -Verbose
	$assets = $response.assets
	if ($IsWindows) {
		$assets = $assets | ? name -Like "*-win-$ProcessorArchitecture*"
	}

	Write-Host 'Select a number for download'
	for ($i = 0; $i -lt $assets.Count; $i++) {
		Write-Host ('{0}) {1}' -f $i, $assets[$i].name)
	}
	$n = Read-Host 'Download'
	$browserDownloadUrl = $assets[$n].browser_download_url

	$outFile = "$DOWNLOADS\$($assets[$n].name)"
	Invoke-WebRequest $browserDownloadUrl -OutFile $outFile -Verbose

	$response.body
	Get-FileHash $outFile -Algorithm SHA256
	$assets[$n].body
}
