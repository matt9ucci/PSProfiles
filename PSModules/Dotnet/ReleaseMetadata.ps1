${releases-index.json} = { Invoke-RestMethod https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json }

<#
.LINK
	.NET Release Notes https://github.com/dotnet/core/tree/main/release-notes
#>
function Get-DotnetReleaseMetadataIndex {
	param (
		[ValidateSet('current', 'eol', 'lts', 'preview')]
		[string[]]
		$SupportPhase
	)

	$index = ${releases-index.json}.Invoke().'releases-index'
	if ($SupportPhase) {
		$index = $index | ? support-phase -In $SupportPhase
	}
	$index
}

<#
.LINK
	.NET Release Notes https://github.com/dotnet/core/tree/main/release-notes
#>
function Get-DotnetReleaseMetadata {
	param (
		[ValidateSet('current', 'eol', 'lts', 'preview')]
		[string[]]
		$SupportPhase = 'lts'
	)

	foreach ($index in Get-DotnetReleaseMetadataIndex -SupportPhase $SupportPhase) {
		Invoke-RestMethod $index.'releases.json'
	}
}

function Get-DotnetLatestSdkMetadata {
	param (
		[ValidateSet('current', 'eol', 'lts', 'preview')]
		[string[]]
		$SupportPhase = 'lts'
	)

	foreach ($r in Get-DotnetReleaseMetadata -SupportPhase $SupportPhase) {
		$latestVersion = $r.'latest-sdk'
		$r.releases.sdk | ? version -EQ $latestVersion
	}
}

function Get-DotnetLatestRuntimeMetadata {
	param (
		[ValidateSet('current', 'eol', 'lts', 'preview')]
		[string[]]
		$SupportPhase = 'lts'
	)

	foreach ($r in Get-DotnetReleaseMetadata -SupportPhase $SupportPhase) {
		$latestVersion = $r.'latest-runtime'
		$r.releases.runtime | ? version -EQ $latestVersion
	}
}
