[CmdletBinding()]
param (
	[Alias('Version')]
	[string]
	$Tag
)

function Get-Release {
	param (
		[Parameter(Mandatory)]
		[string]
		$Owner,

		[Parameter(Mandatory)]
		[string]
		$Repo,

		[Alias('Version')]
		[string]
		$Tag
	)

	$uri = if ($Tag) {
		"https://api.github.com/repos/$Owner/$Repo/releases/tags/$Tag"
	} else {
		"https://api.github.com/repos/$Owner/$Repo/releases/latest"
	}
	Invoke-RestMethod $uri -Method Get -Verbose
}

$release = Get-Release docker buildx $Tag
$buildxUrl = $release.assets.browser_download_url -like '*windows-amd64.exe' | Select-Object -First 1

$outFile = Join-Path "$HOME\.docker\cli-plugins" docker-buildx.exe
Invoke-WebRequest -Uri $buildxUrl -OutFile $outFile -Verbose

$sumUrl = $buildxUrl -replace 'buildx-.+.windows-amd64.exe','checksums.txt'
(Invoke-WebRequest -Uri $sumUrl -Verbose).RawContent

Get-FileHash -Path $outFile -Algorithm SHA256
