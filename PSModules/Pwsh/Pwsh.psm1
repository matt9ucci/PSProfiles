if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml
	$proxy = $pwshProxy.Proxy
	$proxyCredential = $pwshProxy.ProxyCredential

	$PSDefaultParameterValues['Invoke-WebRequest:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-WebRequest:ProxyCredential'] = $proxyCredential
	$PSDefaultParameterValues['Invoke-RestMethod:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-RestMethod:ProxyCredential'] = $proxyCredential
}

. $PSScriptRoot\PwshCompleter.ps1

function Get-PwshLatestVersion {
	(Invoke-RestMethod 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest').tag_name
}

function Save-PwshBinary {
	param (
		[string]
		$Tag,

		[Alias('Architecture')]
		[ValidateSet('arm32', 'arm64', 'x64', 'x86')]
		[string]
		$ProcessorArchitecture = 'x64'
	)

	$uri = if ($Tag) {
		"https://api.github.com/repos/PowerShell/PowerShell/releases/tags/$Tag"
	} else {
		'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
	}

	$response = Invoke-RestMethod $uri -Verbose

	$assets = $response.assets
	if (!(Get-Variable IsWindows -ErrorAction Ignore) -or $IsWindows) {
		$assets = $assets | ? name -Like "*-win-$ProcessorArchitecture*"
	}

	Write-Host 'Select a number for download'
	for ($i = 0; $i -lt $assets.Count; $i++) {
		Write-Host ('{0}) {1}' -f $i, $assets[$i].name)
	}
	$n = Read-Host 'Download'

	$params = @{
		Uri     = $assets[$n].browser_download_url
		OutFile = "$DOWNLOADS\$($assets[$n].name)"
		Verbose = $true
	}
	Invoke-WebRequest @params

	$response.body
	Get-FileHash $params.OutFile -Algorithm SHA256
	$assets[$n].body
}

<#
.NOTES
	$env:POWERSHELL_UPDATECHECK does not work in PowerShell profiles.
	Use this function instead.
.LINK
	About Update Notifications https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_update_notifications
#>
function Set-PwshUpdatecheck {
	param (
		[ValidateSet('Default', 'LTS', 'Off')]
		[string]
		$Value
	)

	[System.Environment]::SetEnvironmentVariable('POWERSHELL_UPDATECHECK', $Value, [System.EnvironmentVariableTarget]::User)
}

function Get-PwshBinaryModuleCustomAttributes {
	param (
		[Parameter(Mandatory)]
		[string]
		$Path
	)

	Import-Module $Path -Force

	([System.AppDomain]::CurrentDomain.GetAssemblies() | ? Location -EQ $Path).CustomAttributes
	| ft AttributeType, ConstructorArguments, Constructor, NamedArguments
}
