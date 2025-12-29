$baseUrl = 'https://api.adoptopenjdk.net/v2'

<#
.EXAMPLE
	Invoke-AdoptOpenJdkApiV2 latestAssets releases openjdk8 -os windows -arch x64 -type jdk -openjdk_impl hotspot

.EXAMPLE
	$params = @{
		RequestType = 'latestAssets'
		ReleaseType = 'releases'
		Version = 'openjdk8'
		os = 'windows'
		arch = 'x64'
		type = 'jdk'
		openjdk_impl = 'hotspot'
	}
	Invoke-AdoptOpenJdkApiV2 @params

.LINK
	https://api.adoptopenjdk.net/
	https://swagger.io/docs/specification/api-host-and-base-path/
#>
function Invoke-AdoptOpenJdkApiV2 {
	param (
		[Parameter(Mandatory)]
		[ValidateSet('info', 'binary', 'latestAssets')]
		[string]
		$RequestType,

		[Parameter(Mandatory)]
		[ValidateSet('releases', 'nightly')]
		[string]
		$ReleaseType,

		[Parameter(Mandatory)]
		[ValidateSet('openjdk8', 'openjdk9', 'openjdk10', 'openjdk11', 'openjdk12', 'openjdk13')]
		[string]
		$Version,

		[Parameter(HelpMessage = 'Open Jdk Implementation')]
		[ArgumentCompletions('hotspot', 'openj9')]
		[string]
		$openjdk_impl,

		[Parameter(HelpMessage = 'Operating System')]
		[ArgumentCompletions('windows', 'linux', 'mac')]
		[string]
		$os,

		[Parameter(HelpMessage = 'Architecture')]
		[ArgumentCompletions('x64', 'x32', 'ppc64', 's390x', 'ppc64le', 'aarch64')]
		[string]
		$arch,

		[Parameter(HelpMessage = 'Binary Type')]
		[ArgumentCompletions('jdk', 'jre')]
		[string]
		$type,

		[Parameter(HelpMessage = 'Heap Size')]
		[ArgumentCompletions('large', 'normal')]
		[string]
		$heap_size,

		[Parameter(HelpMessage = 'Release')]
		[string]
		$release
	)

	$queryParameters = @()
	if ($openjdk_impl) {
		$queryParameters += "openjdk_impl=$openjdk_impl"
	}
	if ($os) {
		$queryParameters += "os=$os"
	}
	if ($arch) {
		$queryParameters += "arch=$arch"
	}
	if ($type) {
		$queryParameters += "type=$type"
	}
	if ($heap_size) {
		$queryParameters += "heap_size=$heap_size"
	}
	if ($release) {
		$queryParameters += "release=$release"
	}

	$uri = "$baseUrl/$RequestType/$ReleaseType/$Version"
	if ($queryParameters) {
		$uri += "`?$($queryParameters -join '&')"
	}

	Invoke-RestMethod -Uri $uri -Method Get -FollowRelLink
}
