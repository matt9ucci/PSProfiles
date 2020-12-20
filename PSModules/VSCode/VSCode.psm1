switch ($env:OS) {
	'Windows_NT' {
		Set-Variable VSCODE_HOME "$HOME/Apps/VSCode" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_USER_DIR "$env:APPDATA\Code\User" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_EXTENSION_DIR "$HOME\.vscode\extensions" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_USER_SETTINGS_JSON "$VSCODE_USER_DIR\settings.json" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_USER_KEYBINDINGS_JSON "$VSCODE_USER_DIR\keybindings.json" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_ZIP_URL https://go.microsoft.com/fwlink/?Linkid=850641 -Option ReadOnly, AllScope -Scope Global -Force
	}
	# Mac $HOME/Library/Application Support/Code/User/settings.json
	# Linux $HOME/.config/Code/User/settings.json
	# See https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations
}

if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml
	$proxy = $pwshProxy.Proxy
	$proxyCredential = $pwshProxy.ProxyCredential

	$PSDefaultParameterValues['Invoke-WebRequest:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-WebRequest:ProxyCredential'] = $proxyCredential
	$PSDefaultParameterValues['Invoke-RestMethod:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-RestMethod:ProxyCredential'] = $proxyCredential
}

. "$PSScriptRoot/Keybindings.ps1"
. "$PSScriptRoot/Settings.ps1"

function Get-VscodeVersion([switch]$Latest) {
	if ($Latest) {
		(Invoke-RestMethod 'https://api.github.com/repos/microsoft/vscode/releases/latest').tag_name
	} else {
		(Invoke-RestMethod 'https://api.github.com/repos/microsoft/vscode/releases').tag_name | sort -Descending
	}
}

function Save-VscodeInstaller {
	param (
		[ArgumentCompleter({
			param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
			(Get-VscodeVersion) -like "$WordToComplete*"
		})]
		[string]
		$Version = 'latest',

		[string]
		$Path
	)

	$uri = "https://update.code.visualstudio.com/$Version/win32-x64-user/stable"

	if (!$Path) {
		$params = @{
			Uri     = $uri
			Method  = 'Head'
			Verbose = $true
		}
		$response = Invoke-WebRequest @params
		$Path = if ($response.Headers.'Content-Disposition'[0] -match '(?=attachment;\s+filename="(.+)")') {
			$Matches[1]
		} else {
			"VscodeInstaller-$Version.exe"
		}
	}

	$params = @{
		Uri     = $uri
		OutFile = $Path
		Verbose = $true
	}
	Invoke-WebRequest @params

	(Resolve-Path $params.OutFile).Path
}

function Save-VscodeArchive {
	param (
		[ArgumentCompleter({
			param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
			(Get-VscodeVersion) -like "$WordToComplete*"
		})]
		[string]
		$Version = 'latest',

		[string]
		$Path
	)

	$uri = "https://update.code.visualstudio.com/$Version/win32-x64-archive/stable"
	if (!$Path) {
		$params = @{
			Uri     = $uri
			Method  = 'Head'
			Verbose = $true
		}
		$response = Invoke-WebRequest @params
		$Path = if ($response.Headers.'Content-Disposition'[0] -match '(?=attachment;\s+filename="(.+)")') {
			$Matches[1]
		} else {
			"Vscode-$Version.zip"
		}
	}

	$params = @{
		Uri     = $uri
		OutFile = $Path
		Verbose = $true
	}
	Invoke-WebRequest @params

	(Resolve-Path $params.OutFile).Path
}

function Install-VscodeArchive {
	param (
		[ArgumentCompleter({
			param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
			(Get-VscodeVersion) -like "$WordToComplete*"
		})]
		[string]
		$Version = 'latest',

		[string]
		$Path
	)

	if ($Version -eq 'latest') {
		$Version = Get-VscodeVersion -Latest
	}

	if (!$Path) {
		$Path = Join-Path $USERAPPS Vscode $Version
	}

	if (Test-Path $Path) {
		throw "Already installed: $Path"
	}

	$archive = Save-VscodeArchive -Version $Version

	Expand-Archive -Path $archive -DestinationPath $Path
	(Resolve-Path $Path).Path
}

function Use-Vscode {
	param (
		[ArgumentCompleter({
			param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)
			$results = @(
				(Get-ChildItem $USERAPPS\Vscode).FullName | % { Join-Path $_ 'bin' }
				"$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"
			) -like "$WordToComplete*"
			$results | % { if ($_ -match ' ') { "'{0}'" -f $_ } else { $_ } }
		})]
		[Parameter(Mandatory)]
		[string]
		$Path
	)

	if (!(Test-Path $Path -PathType Container)) {
		throw "Not found: $Path"
	}

	$codePath = @(
		(Get-ChildItem $USERAPPS\Vscode).FullName | % { Join-Path $_ 'bin' }
		"$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"
	)

	$currentPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User') -split ';'
	$newPath = @(
		$Path
		$currentPath | ? { $_ -notin $codePath }
	)
	[System.Environment]::SetEnvironmentVariable(
		'PATH',
		$newPath -join ';',
		'User'
	)

	Write-Warning 'Restart PowerShell session'
}

function Save-VscodeIcon {
	Invoke-WebRequest https://code.visualstudio.com/favicon.ico -OutFile $USERAPPS\Vscode\favicon.ico
}

function Set-VscodeDirctoryIcon {
	Save-VscodeIcon
	New-Desktop.ini.ps1 -Directory $USERAPPS\Vscode -IconFile $USERAPPS\Vscode\favicon.ico
}

try {
	Get-Command code -ErrorAction Stop > $null
} catch [System.Management.Automation.CommandNotFoundException] {
	Write-Host ('Command `{0}` is required but not found' -f $Error[0].TargetObject) -ForegroundColor Red
}

function Install-VSCodeExtension {
	[CmdletBinding(DefaultParameterSetName = 'Name')]
	param (
		[Parameter(ParameterSetName = 'Name', Mandatory, Position = 0)]
		[string[]]$Name,
		[Parameter(ParameterSetName = 'Recommended', Mandatory)]
		[switch]$Recommended
	)

	if ($Recommended) {
		$Name = (Get-Content "$(Split-Path $PROFILE)\.vscode\extensions.json" | % { $_ -replace '//.*', '' } | ConvertFrom-Json).recommendations
	}
	$Name | % { code --install-extension $_ }
}

function Uninstall-VSCodeExtension {
	[CmdletBinding(DefaultParameterSetName = 'Name')]
	param (
		[Parameter(ParameterSetName = 'Name', Mandatory, Position = 0)]
		[string[]]$Name,
		[Parameter(ParameterSetName = 'All', Mandatory)]
		[switch]$All
	)

	if ($All) {
		$Name = code --list-extensions
	}
	$Name | % { code --uninstall-extension $_ }
}

function Get-VsCodeExtension {
	param (
		[string]$Name = '*',
		[switch]$Full
	)

	$extensions = if ($Full) {
		code --list-extensions --show-versions
	} else {
		code --list-extensions
	}

	$extensions -like "*$Name*"
}
