. $PSScriptRoot\InstallScript.ps1
. $PSScriptRoot\ReleaseMetadata.ps1

function Save-DotnetSdkBinary {
	[CmdletBinding()]
	param (
		[ValidateSet('current', 'eol', 'lts', 'preview')]
		[string[]]
		$SupportPhase = 'lts',

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
		sort version |
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
		[string]
		$Version
	)

	$targetDir = if ($Version) {
		Get-ChildItem $USERAPPS\Dotnet | ? Name -eq $Version
	} else {
		Get-ChildItem $USERAPPS\Dotnet | sort -Descending | select -First 1
	}

	$junctionPath = Join-Path $USERAPPS bin Dotnet
	if (Test-Path $junctionPath) {
		Remove-Item $junctionPath
	}
	New-Item -ItemType Junction -Path (Join-Path $USERAPPS bin Dotnet) -Value $targetDir.FullName | Out-Null

	$env:DOTNET_MULTILEVEL_LOOKUP = $false
}

function Show-DotnetDownloadPage {
	param (
		[string]
		$ChannelVersion = (Get-DotnetChannelVersion -Lts -Latest)
	)

	Start-Process "https://dotnet.microsoft.com/download/dotnet-core/$ChannelVersion"
}

Register-ArgumentCompleter -CommandName dotnet, .n, .nh -ScriptBlock {
	param($commandName, $wordToComplete, $cursorPosition)
	dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}
