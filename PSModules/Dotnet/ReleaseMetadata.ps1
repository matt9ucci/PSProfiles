$ReleaseMetadataCache = [pscustomobject]@{
	releasesIndexJson = $null
}

# See: .NET Core Release Notes https://github.com/dotnet/core/blob/master/release-notes/README.md
$ReleaseMetadataCache | Add-Member ScriptProperty 'releases-index.json' {
	if (!$this.releasesIndexJson) {
		$response = Invoke-RestMethod https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json
		$this.releasesIndexJson = $response.'releases-index' | sort channel-version -Descending
	}
	$this.releasesIndexJson
}

function Clear-ReleaseMetadataCache {
	$ReleaseMetadataCache.releasesIndexJson = $null
}

function Get-ChannelVersion {
	[CmdletBinding(DefaultParameterSetName = 'SupportPhase')]
	param (
		[Parameter(ParameterSetName = 'SupportPhase', Position = 0)]
		[ValidateSet('current', 'eol', 'lts', 'preview')]
		[string[]]
		$SupportPhase = @('current', 'lts'),

		[Parameter(ParameterSetName = 'Lts')]
		[switch]
		$Lts,

		[switch]
		$Latest
	)

	$json = $ReleaseMetadataCache.'releases-index.json'

	$json = switch ($PSCmdlet.ParameterSetName) {
		SupportPhase { $json | ? support-phase -in $SupportPhase }
		Lts { if ($Lts) { $json | ? support-phase -eq lts } }
	}

	if ($Latest) {
		$json = $json | sort channel-version -Bottom 1
	}

	$json.'channel-version' | sort -Descending
}

<#
.LINK
	.NET Core Release Notes https://github.com/dotnet/core/blob/master/release-notes/README.md
#>
function Get-ReleaseMetadata {
	param (
		[string]
		$ChannelVersion = (Get-DotnetChannelVersion -Lts -Latest),

		[switch]
		$Latest
	)

	$channelMetadata = Invoke-RestMethod https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/$ChannelVersion/releases.json
	$releaseMetadata = $channelMetadata.releases
	if ($Latest) {
		$releaseMetadata = $releaseMetadata | ? release-version -eq $channelMetadata.'latest-release'
	}
	$releaseMetadata
}
