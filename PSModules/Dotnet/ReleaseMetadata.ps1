${releases-index.json} = { Invoke-RestMethod https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json }

<#
.LINK
	.NET Release Notes https://github.com/dotnet/core/tree/main/release-notes
#>
function Get-DotnetReleaseMetadataIndex {
	param (
		[SupportPhase[]]
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
		[SupportPhase[]]
		$SupportPhase = [SupportPhase]::lts
	)

	foreach ($index in Get-DotnetReleaseMetadataIndex -SupportPhase $SupportPhase) {
		Invoke-RestMethod $index.'releases.json'
	}
}

function Get-DotnetLatestSdkMetadata {
	param (
		[SupportPhase[]]
		$SupportPhase = [SupportPhase]::lts
	)

	foreach ($r in Get-DotnetReleaseMetadata -SupportPhase $SupportPhase) {
		$latestVersion = $r.'latest-sdk'
		$r.releases.sdk | ? version -EQ $latestVersion
	}
}

function Get-DotnetLatestRuntimeMetadata {
	param (
		[SupportPhase[]]
		$SupportPhase = [SupportPhase]::lts
	)

	foreach ($r in Get-DotnetReleaseMetadata -SupportPhase $SupportPhase) {
		$latestVersion = $r.'latest-runtime'
		$r.releases.runtime | ? version -EQ $latestVersion
	}
}

function Get-DotnetChannelVersion {
	param (
		[SupportPhase[]]
		$SupportPhase
	)

	if ($SupportPhase) {
		(Get-DotnetReleaseMetadataIndex -SupportPhase $SupportPhase).'channel-version'
	} else {
		(Get-DotnetReleaseMetadataIndex).'channel-version'
	}
}
