$InstallScriptInstallDir = if ($IsLinux -or $IsMacOS) {
	'/usr/share/dotnet'
} else {
	"$env:LOCALAPPDATA\Microsoft\dotnet"
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

function Install-DotnetCliByInstallScript {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[string]
		$Channel = 'LTS',

		[string]
		$Version = 'Latest'
	)

	$installScript = Save-DotnetInstallScript -Path (Join-Path $env:TEMP $InstallScriptName)

	$param = @{
		Channel = $Channel
		Version = $Version
		DryRun  = -not $PSCmdlet.ShouldProcess($installScript, 'Install .NET Core CLI')
	}
	& $installScript @param
}

function Uninstall-DotnetCliByInstallScript {
	Remove-Item $InstallScriptInstallDir -Recurse -Force
}
