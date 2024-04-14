<#
.EXAMPLE
	$config = @{ RootInstallationLocation = $HOME }
	Import-Module NodeJs -ArgumentList $config
#>
param (
	[hashtable]$UserConfiguration
)

if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml
	$proxy = $pwshProxy.Proxy
	$proxyCredential = $pwshProxy.ProxyCredential

	$PSDefaultParameterValues['Invoke-WebRequest:Proxy'] = $proxy
	$PSDefaultParameterValues['Invoke-WebRequest:ProxyCredential'] = $proxyCredential
}

[hashtable]$defaultConfiguration = @{
	RootInstallationLocation = Join-Path $HOME Apps NodeJs
}

[hashtable]$config = $defaultConfiguration.Clone()
foreach ($key in $UserConfiguration.Keys) {
	$config[$key] = $UserConfiguration[$key]
}

. $PSScriptRoot\Binary.ps1
. $PSScriptRoot\DistributionIndex.ps1

function Save-NodeJsIcon {
	param (
		[string]
		$Path
	)

	$uri = 'https://raw.githubusercontent.com/nodejs/node/master/src/res/node.ico'
	if (-not $Path) {
		$Path = Join-Path $config['RootInstallationLocation'] (Split-Path $uri -Leaf)
	}
	Invoke-WebRequest $uri -OutFile $Path
	Get-Item $Path
}

function Get-NodeJsModuleConfiguration {
	param (
		[ValidateSet('Default', 'User', 'Current')]
		[string]
		$Scope = 'Current'
	)

	switch ($Scope) {
		'Default' { $defaultConfiguration }
		'User' { $UserConfiguration }
		'Current' { $config }
	}
}

function Get-NodeJsVersion {
	foreach ($d in Get-ChildItem $config['RootInstallationLocation'] -Directory) {
		$node = Get-ChildItem $d -Filter node.exe
		if (!$node) { continue; }

		[pscustomobject]@{
			Version = & $node --version
			FullName = $node.FullName
		}
	}
}

<#
.EXAMPLE
	Install-NodeJs v12.14.1
#>
function Install-NodeJs {
	param (
		[string]
		$Version
	)

	[string]$binaryPath = Save-NodeJsBinary -Version $Version
	Expand-NodeJSBinary -Path $binaryPath -DestinationPath $config['RootInstallationLocation']
}

<#
.EXAMPLE
	Uninstall-NodeJs v12.14.1
#>
function Uninstall-NodeJs {
	param (
		[string]
		$Version
	)

	Remove-Item (Join-Path $config['RootInstallationLocation'] $Version) -Recurse -Confirm
}

function Get-NodeJsEnv {
	param (
		[string]
		$Name = '*'
	)

	(node -e 'console.log(process.env)' | ConvertFrom-Json -AsHashtable).GetEnumerator()
	 | ? Name -Like $Name
	 | Sort-Object -Property Name
	 | % { $result = [ordered]@{} } { $result[$_.Name] =$_.Value } { $result }
}

<#
.EXAMPLE
	Open-NodeJsLocation
	# Opens root directory
.EXAMPLE
	Open-NodeJsLocation v12.14.1
	# Opens v12.14.1 directory (if it exists) or root directory
#>
function Open-NodeJsLocation {
	param (
		[string]
		$Version
	)

	Invoke-Item (Join-Path $config['RootInstallationLocation'] $Version)
}

function Use-NodeJs {
	param (
		[string]
		$Version
	)

	$item = if ($Version) {
		Get-Item (Join-Path $config['RootInstallationLocation'] $Version)
	} else {
		Get-ChildItem $config['RootInstallationLocation'] -Filter v* -Directory | Sort-Object Name -Bottom 1
	}

	$currentPath = $env:Path -split [System.IO.Path]::PathSeparator

	# Add/Move the target NodeJS to the beginning of the current PATH
	$env:Path = (@($item.FullName) + ($currentPath -ne $item.FullName)) -join [System.IO.Path]::PathSeparator
}

Register-ArgumentCompleter -ParameterName Version -CommandName Install-NodeJs -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)
	(& $DistributionIndex).version -like "$wordToComplete*"
}

Register-ArgumentCompleter -ParameterName Version -CommandName @(
	'Open-NodeJsLocation'
	'Uninstall-NodeJs'
	'Use-NodeJs'
) -ScriptBlock {
	param ($commandName, $parameterName, $wordToComplete)
	@(, (Get-NodeJsVersion | % Version)) -like "$wordToComplete*"
}
