if ($IsWindows) {
	Set-Variable VSCODE_HOME "$env:LOCALAPPDATA\Programs\Microsoft VS Code" -Option ReadOnly, AllScope -Scope Global -Force
	Set-Variable VSCODE_USER_DIR "$env:APPDATA\Code" -Option ReadOnly, AllScope -Scope Global -Force
	Set-Variable VSCODE_USER_SNIPPETS_DIR "$VSCODE_USER_DIR\User\snippets\" -Option ReadOnly, AllScope -Scope Global -Force
	Set-Variable VSCODE_USER_SETTINGS_JSON "$VSCODE_USER_DIR\User\settings.json" -Option ReadOnly, AllScope -Scope Global -Force
	Set-Variable VSCODE_USER_KEYBINDINGS_JSON "$VSCODE_USER_DIR\User\keybindings.json" -Option ReadOnly, AllScope -Scope Global -Force
} else {
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
		(Invoke-RestMethod 'https://api.github.com/repos/microsoft/vscode/releases').tag_name | Sort-Object -Descending
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
		$Path = '.'
	)

	$uri = "https://update.code.visualstudio.com/$Version/win32-x64-user/stable"

	$params = @{
		Uri     = $uri
		Method  = 'Head'
		Verbose = $true
	}
	$response = Invoke-WebRequest @params

	$fileName = if ($response.Headers.'Content-Disposition'[0] -match '(?=attachment;\s+filename="(.+)")') {
		$Matches[1]
	} else {
		Write-Warning 'filename not found'
		"VscodeInstaller-$Version.exe"
	}

	$params = @{
		Uri     = $uri
		OutFile = Join-Path $Path $fileName
		Verbose = $true
	}
	Invoke-WebRequest @params

		(Resolve-Path $params.OutFile).Path
}

function Invoke-VscodeInstaller {
	param (
		[string]
		$Path
	)

	Start-Process $Path @("/DIR=$(Join-Path $USERAPPS Vscode)")
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
	New-Desktop.ini.ps1 -Directory $VSCODE_HOME -IconFile $VSCODE_HOME\Code.exe
}

try {
	Get-Command code -ErrorAction Stop > $null
} catch [System.Management.Automation.CommandNotFoundException] {
	Write-Host ('Command `{0}` is required but not found' -f $Error[0].TargetObject) -ForegroundColor Red
}

function Install-VscodeExtension {
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

function Uninstall-VscodeExtension {
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

function Get-VsCodeExtension([string]$Name = '*', [switch]$Full) {
	[string[]]$extensions = code --list-extensions --show-versions $(if ($Full) { 'true' } else { 'false' })
	$extensions -like "*$Name*"
}

function Update-VscodeUserSnippetsJson {
	Copy-Item $PSScriptRoot\snippets\*.json $VSCODE_USER_SNIPPETS_DIR
}

<#
	.SYNOPSIS
		VS Code opens Remote Repository (rr) from GitHub
	.LINK
		https://github.com/microsoft/vscode/blob/791b350c034b3a488a54ec2b6cd1cc017d702f1f/src/vs/platform/environment/node/argv.ts#L85
		https://github.com/microsoft/vscode/wiki/Virtual-Workspaces#review-that-the-code-is-ready-for-virtual-resources
	#>
function coderr {
	param (
		[ArgumentCompleter(
			{
				param ([string]$CommandName, [string]$ParameterName, [string]$WordToComplete)

				$params = @{
					Uri           = 'https://api.github.com/users/matt9ucci/starred'
					FollowRelLink = $true
				}
				[string[]]$fullNames = ((Invoke-RestMethod @params).full_name | Sort-Object)
				$fullNames -like "$WordToComplete*"
			}
		)]
		[string]
		$FullName
	)
	code --folder-uri "vscode-vfs://github/$FullName"
}

function Expand-VscodeInsiderZip {
	param (
		[Parameter(Position = 0, Mandatory)]
		[string]
		$Path
	)

	Expand-VscodeArchivePortable -Path $Path -Destination $USERAPPS\VscodeInsider
}

function Expand-VscodeArchivePortable {
	param (
		[Parameter(Position = 0, Mandatory)]
		[string]
		$Path,

		[Parameter(Position = 1, Mandatory)]
		[string]
		$Destination
	)

	Rename-Item -Path $Destination -NewName "$(Split-Path $Destination -Leaf)-$(Get-Date -Format yyMMddHHmmss)" -ErrorAction Continue -Verbose
	Expand-Archive -Path $Path -DestinationPath $Destination -ErrorAction Stop
	New-Item -Path $Destination\data -ItemType Directory -Verbose | Out-Null
	New-Item -Path $Destination\data\tmp -ItemType Directory -Verbose | Out-Null

	& (Get-Item $Destination\bin\code*.cmd) --version
}

<#
.LINK
	https://code.visualstudio.com/docs/setup/uninstall
#>
function Uninstall-Vscode {
	winget uninstall --source winget --exact --id Microsoft.VisualStudioCode
	Remove-Item -Path $env:APPDATA/Code -Recurse -Confirm
	Remove-Item -Path $HOME/.vscode -Recurse -Confirm
	Remove-Item -Path $VSCODE_HOME -Recurse -Confirm
}
