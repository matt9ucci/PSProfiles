$DOTNET_CLI4USER_ROOT = if ($IsLinux -or $IsMacOS) {
	'/usr/share/dotnet'
} else {
	"$env:LOCALAPPDATA\Microsoft\dotnet"
}

$installScriptName = 'dotnet-install.ps1'

. $PSScriptRoot\ReleaseMetadata.ps1

function Install-DotnetCli4User {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[string]
		$Channel = 'LTS',

		[string]
		$Version = 'Latest'
	)

	$installScript = Save-DotnetInstallScript -Path (Join-Path $env:TEMP $installScriptName)

	$param = @{
		Channel = $Channel
		Version = $Version
		DryRun  = -not $PSCmdlet.ShouldProcess($installScript, 'Install .NET Core CLI')
	}
	& $installScript @param
}

function Uninstall-DotnetCli4User {
	Remove-Item $DOTNET_CLI4USER_ROOT -Recurse -Force
}

function Save-DotnetInstallScript {
	param (
		[string]
		$Path = $installScriptName
	)

	if (Test-Path $Path) {
		Write-Warning "$Path already exists."
	} else {
		$param = @{
			Uri     = 'https://dot.net/v1/dotnet-install.ps1'
			OutFile = $Path
		}
		Invoke-WebRequest @param
	}

	Get-Item $Path
}

function Save-SdkBinary {
	param (
		[Parameter(Mandatory)]
		[ValidateSet('linux-arm', 'linux-arm64', 'linux-musl-x64', 'linux-x64', 'osx-x64', 'rhel.6-x64', 'win-arm', 'win-x64', 'win-x86')]
		[string]
		$Rid,

		[string]
		$ChannelVersion = (Get-DotnetChannelVersion -Lts -Latest),

		[string]
		$Location = (Get-Location)
	)

	$releaseMetadata = Get-DotnetReleaseMetadata -ChannelVersion $ChannelVersion -Latest
	$sdk = $releaseMetadata.sdk.files | ? rid -EQ $Rid | ? name -Match '\w+\.(zip|tar\.gz)$'

	$outFile = Join-Path $Location $sdk.name

	$params = @{
		Uri     = $sdk.url
		OutFile = $outfile
		Verbose = $true
	}
	Invoke-WebRequest @params

	$fileHashInfo = Get-FileHash $outFile -Algorithm SHA512
	if ($fileHashInfo.Hash -eq $sdk.hash) {
		Write-Information ('Valid hash [{0}]' -f $fileHashInfo.Hash)
		(Resolve-Path $outFile).Path
	} else {
		throw 'Invalid hash [{0}]: expected [{1}]' -f $fileHashInfo.Hash, $sdk.hash
	}
}

function Use-Sdk {
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
