[scriptblock]$DistributionIndex = & {
	$cache = $null
	if ($proxy) { $proxy = $proxy }
	if ($proxyCredential) { $proxyCredential = $proxyCredential }

	{
		param ([switch]$Force)

		if ($proxy) {
			$PSDefaultParameterValues['Invoke-WebRequest:Proxy'] = $proxy
		}
		if ($proxyCredential) {
			$PSDefaultParameterValues['Invoke-WebRequest:ProxyCredential'] = $proxyCredential
		}

		if (!$cache -or $Force) {
			$uri = 'https://nodejs.org/dist/index.json'
			$script:cache = Invoke-WebRequest $uri | ConvertFrom-Json
		}
		$cache
	}.GetNewClosure()
}

<#
.EXAMPLE
	Get-NodeJsDistributionIndex -Lts -Latest

	version  : v12.14.1
	date     : 2020-01-07
	files    : {aix-ppc64, headers, linux-arm64, linux-armv7l…}
	npm      : 6.13.4
	v8       : 7.7.299.13
	uv       : 1.33.1
	zlib     : 1.2.11
	openssl  : 1.1.1d
	modules  : 72
	lts      : Erbium
	security : False

.LINK
	nodejs-dist-indexer https://github.com/nodejs/nodejs-dist-indexer
	Adding a "security" property to dist/index.json #437 https://github.com/nodejs/Release/issues/437
#>
function Get-NodeJsDistributionIndex {
	param (
		[switch]
		$Force,
		[switch]
		$Lts,
		[switch]
		$Security,
		[switch]
		$Latest
	)

	$result = & $DistributionIndex -Force:$Force
	if ($Lts) {
		$result = $result | ? lts -NE $false
	}
	if ($Security) {
		$result = $result | ? security -EQ $true
	}

	if ($Latest) {
		$result | Sort-Object { [version]$_.version.TrimStart('v') } -Bottom 1
	} else {
		$result | Sort-Object { [version]$_.version.TrimStart('v') }
	}
}

<#
.EXAMPLE
	Get-NodeJsDistributionVersion -Lts -Latest

	v12.14.1
#>
function Get-NodeJsDistributionVersion {
	param (
		[switch]
		$Force,
		[switch]
		$Lts,
		[switch]
		$Security,
		[switch]
		$Latest
	)

	Get-NodeJsDistributionIndex @PSBoundParameters | % version
}
