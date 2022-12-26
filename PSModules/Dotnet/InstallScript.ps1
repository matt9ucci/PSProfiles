$InstallScriptInstallDir = if ($IsLinux -or $IsMacOS) {
	'/usr/share/dotnet'
} else {
	$DotnetRoot
}

$InstallScriptName = 'dotnet-install.ps1'

function Save-DotnetInstallScript {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[string]
		$Path = $InstallScriptName,

		[switch]
		$Force
	)

	if ((Test-Path $Path) -and !$Force -and !$PSCmdlet.ShouldContinue($Path, 'Overwrite the existing script:')) {
		return Get-Item $Path
	}

	if ($PSCmdlet.ShouldProcess($Path)) {
		$params = @{
			Uri     = 'https://dot.net/v1/dotnet-install.ps1'
			OutFile = $Path
			Verbose = $true
		}
		Invoke-WebRequest @params

		Get-Item $Path
	}
}

function Install-DotnetSdkByInstallScript {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[ArgumentCompleter( { Get-DotnetChannelVersion })]
		[string]
		$Channel = (Get-DotnetChannelVersion -SupportPhase lts | Sort-Object | select -Last 1),

		[ValidateSet('daily', 'GA', 'preview', 'signed', 'validated')]
		[string]
		$Quality = 'GA',

		[string]
		$InstallDir
	)

	if (!$InstallDir) {
		# Set folder name temporarily
		$tmpInstallDir = Join-Path $InstallScriptInstallDir tmp
	}

	$installScript = Save-DotnetInstallScript -Path (Join-Path $env:TEMP $InstallScriptName)

	$params = @{
		Channel    = $Channel
		Quality    = $Quality
		InstallDir = if ($InstallDir) { $InstallDir } else { $tmpInstallDir }
		NoPath     = $true
		DryRun     = -not $PSCmdlet.ShouldProcess($installScript, 'Install .NET SDK')
	}
	& $installScript @params

	if ($tmpInstallDir) {
		# Set folder name formally
		Rename-Item -Path $tmpInstallDir -NewName (&(Join-Path $tmpInstallDir dotnet) --version)
	}
}

function Uninstall-DotnetCliByInstallScript {
	Remove-Item $InstallScriptInstallDir -Recurse -Force
}
