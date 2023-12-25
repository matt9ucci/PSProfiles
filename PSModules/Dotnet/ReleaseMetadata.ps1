${releases-index} = [System.Lazy[Object[]]]::new(
	[System.Func[Object[]]] {
		(Invoke-RestMethod https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json).'releases-index'
	}
)

<#
.LINK
	.NET Release Notes https://github.com/dotnet/core/tree/main/release-notes
#>
function Get-DotnetReleaseMetadataIndex {
	param (
		[SupportPhase[]]
		$SupportPhase
	)

	if ($SupportPhase.Count) {
		${releases-index}.Value | ? support-phase -In $SupportPhase
	} else {
		${releases-index}.Value
	}
}

<#
.LINK
	.NET Release Notes https://github.com/dotnet/core/tree/main/release-notes
#>
function Get-DotnetReleaseMetadata {
	param (
		[SupportPhase[]]
		$SupportPhase = [SupportPhase]::active
	)

	foreach ($index in Get-DotnetReleaseMetadataIndex -SupportPhase $SupportPhase) {
		Invoke-RestMethod $index.'releases.json'
	}
}

function Get-DotnetLatestSdkMetadata {
	param (
		[SupportPhase[]]
		$SupportPhase = [SupportPhase]::active
	)

	foreach ($r in Get-DotnetReleaseMetadata -SupportPhase $SupportPhase) {
		$latestVersion = $r.'latest-sdk'
		$r.releases.sdk | ? version -EQ $latestVersion
	}
}

function Get-DotnetLatestRuntimeMetadata {
	param (
		[SupportPhase[]]
		$SupportPhase = [SupportPhase]::active
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
