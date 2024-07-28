[CmdletBinding()]
param (
	[Alias('Version')]
	[string]
	$Tag,

	[switch]
	$Force
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

if (Get-Command docker-compose -ErrorAction Ignore) {
	Write-Warning "$(docker-compose version) already exists"
	if (!$Force) {
		return
	}
}

$release = Get-Release docker compose $Tag
$composeUrl = $release.assets.browser_download_url -like '*Windows-x86_64.exe' | Select-Object -First 1

$outFile = Join-Path "$HOME\.docker\cli-plugins" docker-compose.exe
Invoke-WebRequest -Uri $composeUrl -OutFile $outFile -Verbose

$sumUrl = $composeUrl + '.sha256'
(Invoke-WebRequest -Uri $sumUrl -Verbose).RawContent

Get-FileHash -Path $outFile -Algorithm SHA256
