$DOTNET_CLI4USER_ROOT = if ($IsLinux -or $IsMacOS) {
	'/usr/share/dotnet'
} else {
	"$env:LOCALAPPDATA\Microsoft\dotnet"
}

$installScriptName = 'dotnet-install.ps1'

. $PSScriptRoot\ReleaseMetadata.ps1

function Install-Cli4User {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[string]
		$Channel = 'LTS',

		[string]
		$Version = 'Latest'
	)

	$installScript = Save-InstallScript -Path (Join-Path $env:TEMP $installScriptName)

	$param = @{
		Channel = $Channel
		Version = $Version
		DryRun  = -not $PSCmdlet.ShouldProcess($installScript, 'Install .NET Core CLI')
	}
	& $installScript @param
}

function Uninstall-Cli4User {
	Remove-Item $DOTNET_CLI4USER_ROOT -Recurse -Force
}

function Save-InstallScript {
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
		$Location = $env:TEMP
	)

	$releaseMetadata = Get-DotnetReleaseMetadata -ChannelVersion $ChannelVersion -Latest
	$fileMetadata = $releaseMetadata.sdk.files | ? rid -EQ $Rid | ? name -Match '\w+\.(zip|tar\.gz)$'

	$outFile = Join-Path $Location $fileMetadata.name
	Invoke-WebRequest $fileMetadata.url -OutFile $outFile -Verbose

	$fileHashInfo = Get-FileHash $outFile -Algorithm SHA512
	if ($fileHashInfo.Hash.ToUpper() -eq $fileMetadata.hash.ToUpper()) {
		Write-Information ('Valid hash [{0}]' -f $fileHashInfo.Hash.ToUpper())
		(Resolve-Path $outFile).Path
	} else {
		throw 'Invalid hash [{0}]: expected [{1}]' -f $fileHashInfo.Hash.ToUpper(), $fileMetadata.hash.ToUpper()
	}
}

function Show-DownloadPage {
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
