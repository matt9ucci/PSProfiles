$wslPath = 'wsl'
$wsl = Get-Command -Name $wslPath -ErrorAction Stop

$env:WSL_DISTRO_DIRECTORY ??= 'C:\WslDistro'
$env:WSL_USER ??= 'wsl-user'

function Get-WslDistro {
	param (
		[switch]
		$Online
	)

	$scriptBlock = if ($Online) {
		{
			foreach ($line in $(& $using:wsl --list --online).Where({ $_ -match 'NAME\s+.+$' }, 'SkipUntil') | Select-Object -Skip 1) {
				$name, $friendlyName = $line -split '\s{4,}'
				[pscustomobject]@{
					Name         = $name.Trim()
					FriendlyName = $friendlyName.Trim()
				}
			}
		}
	} else {
		{
			foreach ($line in $(& $using:wsl --list --verbose).Where({ $_ -match 'NAME\s+.+$' }, 'SkipUntil') | Select-Object -Skip 1) {
				$name, $state, $version = $line -split '\s{4,}'
				$default = $name -match '\*\s\w+'
				[pscustomobject]@{
					Default = $default
					Name    = $name.Trim('*').Trim()
					State   = $state
					Version = $version
				}
			}
		}
	}

	$params = @{
		InitializationScript = { $env:WSL_UTF8 = 1 }
		ScriptBlock          = $scriptBlock
	}

	Start-Job @params | Receive-Job -Wait -AutoRemoveJob | Select-Object $(
		if ($Online) {
			'Name', 'FriendlyName'
		} else {
			'Default', 'Name', 'State', 'Version'
		}
	)
}

function Register-WslDistro {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	& $wsl --install $Name
}

function Unregister-WslDistro {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	if ($PSCmdlet.ShouldProcess($Name, 'wsl --unregister')) {
		& $wsl --unregister $Name
	}
}

Register-ArgumentCompleter -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)

	foreach ($available in (Get-WslDistro -Online | ? $parameterName -Like "$wordToComplete*")) {
		[System.Management.Automation.CompletionResult]::new(
			$available.Name, $available.Name, 'Text', $available.FriendlyName
		)
	}
} -CommandName @(
	'Register-WslDistro'
)

Register-ArgumentCompleter -ParameterName Name -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)

	foreach ($installed in (Get-WslDistro | ? $parameterName -Like "$wordToComplete*")) {
		[System.Management.Automation.CompletionResult]::new(
			$installed.Name, $installed.Name, 'Text', "$installed."
		)
	}
} -CommandName @(
	'Unregister-WslDistro'
	'Export-WslDistro'
	'Import-WslDistro'
	'Stop-WslDistro'
	'Set-WslDistroDefaultUser'
)

function Export-WslDistro {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	if (!(Test-Path $env:WSL_DISTRO_DIRECTORY)) {
		New-Item -Path $env:WSL_DISTRO_DIRECTORY -ItemType Directory -ErrorAction Stop
	}

	$tar = Join-Path $env:WSL_DISTRO_DIRECTORY "$Name.tar"

	& $wsl --export $Name $tar | Out-Null

	return Get-Item -Path $tar
}

function Import-WslDistro {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name,

		[Parameter(Mandatory)]
		[string]
		$TarPath
	)

	if (!(Test-Path $env:WSL_DISTRO_DIRECTORY)) {
		New-Item -Path $env:WSL_DISTRO_DIRECTORY -ItemType Directory -ErrorAction Stop
	}

	if (!(Test-Path $TarPath)) {
		throw "Cannot find path '$TarPath' because it does not exist."
	}

	& $wsl --import $Name (Join-Path $env:WSL_DISTRO_DIRECTORY $Name) $TarPath
}

function Set-WslDistroDefaultUser {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name,

		[Parameter(Mandatory)]
		[string]
		$UserName
	)

	$params = @(
		'--distribution', $Name
		'--user', 'root'
		'echo', "[user]`ndefault=$UserName", '>>', '/etc/wsl.conf'
	)
	& $wsl @params
}

function Stop-WslDistro {
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	& $wsl --distribution $Name --shutdown
}
