# https://github.com/SchemaStore/schemastore/blob/master/src/schemas/json/dotnet-releases-index.json
# https://github.com/dotnet/deployment-tools/blob/main/src/Microsoft.Deployment.DotNet.Releases/src/SupportPhase.cs
enum SupportPhase {
	active
	eol
	golive
	maintenance
	preview
	unknown
}

$DotnetRoot = if ($IsLinux -or $IsMacOS) {
	'/usr/share/dotnet'
} else {
	"$USERAPPS\Dotnet"
}

. $PSScriptRoot\InstallScript.ps1
. $PSScriptRoot\ReleaseMetadata.ps1

function Save-DotnetSdkBinary {
	[CmdletBinding()]
	param (
		[SupportPhase[]]
		$SupportPhase = [SupportPhase]::active,

		[ValidateSet('linux-arm', 'linux-arm64', 'linux-musl-x64', 'linux-x64', 'osx-x64', 'rhel.6-x64', 'win-arm', 'win-x64', 'win-x86')]
		[string]
		$Rid,

		[string]
		$Location = (Get-Location)
	)

	if (!$PSBoundParameters.ContainsKey('Rid')) {
		$Rid = if ($IsWindows) {
			'win-x64'
		}
	}

	$sdk = Get-DotnetLatestSdkMetadata -SupportPhase $SupportPhase |
	Sort-Object version |
	select -Last 1 |
	% files |
	? rid -EQ $Rid |
	? name -Match '\w+\.(zip|tar\.gz)$'

	$params = @{
		Uri     = $sdk.url
		OutFile = Join-Path $Location (Split-Path $sdk.url -Leaf)
		Verbose = $true
	}
	Invoke-WebRequest @params

	$fileHashInfo = Get-FileHash $params.OutFile -Algorithm SHA512
	if ($fileHashInfo.Hash -eq $sdk.hash) {
		Write-Information ('Valid hash [{0}]' -f $fileHashInfo.Hash)
		(Resolve-Path $params.OutFile).Path
	} else {
		throw 'Invalid hash [{0}]: expected [{1}]' -f $fileHashInfo.Hash, $sdk.hash
	}
}

function Use-DotnetSdk {
	param (
		[ArgumentCompleter({
				param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
				@(Get-ChildItem "$USERAPPS\Dotnet" -Name) -like "$WordToComplete*"
			})]
		[string]
		$Version
	)

	$targetDir = if ($Version) {
		Get-ChildItem $DotnetRoot | ? Name -EQ $Version
	} else {
		Get-ChildItem $DotnetRoot | Sort-Object | select -Last 1
	}


	if (Test-Path ($junctionPath = Join-Path $HOME Commands Dotnet)) {
		Remove-Item $junctionPath
	}

	$params = @{
		ItemType = 'Junction'
		Path     = $junctionPath
		Value    = $targetDir.FullName
	}
	New-Item @params | Out-Null

	$env:DOTNET_MULTILEVEL_LOOKUP = $false
}

function Show-DotnetDownloadPage {
	param (
		[ArgumentCompleter( { Get-DotnetChannelVersion })]
		[string]
		$ChannelVersion = (Get-DotnetChannelVersion -SupportPhase active)
	)

	Start-Process "https://dotnet.microsoft.com/en-us/download/dotnet/$ChannelVersion"
}

<#
.NOTES
	Default 0 (false).
.LINK
	Environment variables used by .NET SDK, .NET CLI, and .NET runtime https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-environment-variables#dotnet_multilevel_lookup
#>
function Set-DotnetMultilevelLookup {
	param (
		[bool]
		$Value = $false
	)

	[System.Environment]::SetEnvironmentVariable('DOTNET_MULTILEVEL_LOOKUP', [int]$Value, [System.EnvironmentVariableTarget]::User)
}

Register-ArgumentCompleter -CommandName dotnet, .n -ScriptBlock {
	param ($commandName, $wordToComplete, $cursorPosition)
	dotnet complete --position $cursorPosition $wordToComplete | % {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}
