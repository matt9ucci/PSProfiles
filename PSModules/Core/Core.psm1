. $PSScriptRoot\Administrator.ps1
. $PSScriptRoot\Command.ps1
. $PSScriptRoot\Directory.ps1

function New-Junction {
	param (
		[Parameter(Mandatory, Position = 0)]
		[Alias('Target')]
		[string]
		$Value,

		[string]
		$Path = '.',

		[string]
		$Name = (Split-Path $Value -Leaf)
	)

	New-Item -Path $Path -Name $Name -Value $Value -ItemType Junction
}

function New-SymbolicLink {
	param (
		[Parameter(Mandatory, Position = 0)]
		[Alias('Target')]
		[string]
		$Value,

		[string]
		$Path = '.',

		[string]
		$Name = (Split-Path $Value -Leaf)
	)

	New-Item -Path $Path -Name $Name -Value $Value -ItemType SymbolicLink
}

function Get-Accelerator([string]$Name = '*') {
	$accelerators = [powershell].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
	$accelerators.GetEnumerator() | Where-Object Key -Like $Name | Sort-Object -Property Key
}

function Edit-Hosts { saps notepad $env:SystemRoot\System32\drivers\etc\hosts -Verb RunAs }
function Edit-SshConfig { code $HOME\.ssh\config }

function Export-HttpProxyCredential([string]$Path = "$HOME\.psprofiles\HttpProxyCredential.xml") {
	Get-Credential | Export-Clixml $Path
}

function Export-PwshProxyClixml {
	param (
		[Parameter(Mandatory)]
		[uri]
		$Proxy,

		[pscredential]
		$ProxyCredential = (Get-Credential -UserName $env:USERNAME),

		[string]
		$Path = (Join-Path (Split-Path $PROFILE) PwshProxy.xml)
	)

	$pwshProxy = [pscustomobject]@{
		Proxy = $Proxy
		ProxyCredential = $ProxyCredential
	}

	Export-Clixml -Path $Path -InputObject $pwshProxy
}

<#
.LINK
	https://docs.github.com/en/rest/reference/licenses#get-all-commonly-used-licenses
#>
function Get-LicenseFromGithub {
	param (
		[ValidateSet('apache-2.0', 'mit', 'mpl-2.0')]
		[string]
		$Key
	)

	$params = @{
		Uri = 'https://api.github.com/licenses' + ($Key ? "/$Key" : '')
	}
	Invoke-RestMethod @params
}

<#
.LINK
	https://docs.github.com/en/rest/reference/licenses#get-a-license
#>
function New-LicenseFile {
	param (
		[ValidateSet('agpl-3.0', 'apache-2.0', 'bsd-2-clause', 'bsd-3-clause', 'bsl-1.0', 'cc0-1.0', 'epl-2.0', 'gpl-2.0', 'gpl-3.0', 'lgpl-2.1', 'mit', 'mpl-2.0', 'unlicense')]
		[Parameter(Mandatory)]
		[string]
		$Key,

		[switch]
		$Commit
	)

	$response = Get-LicenseFromGithub $Key

	$licenseText = $response.body
	if ($key -eq 'mit') {
		$licenseText = $licenseText -replace '\[year\]', [datetime]::Today.Year
		$licenseText = $licenseText -replace '\[fullname\]', 'Masatoshi Higuchi'
	}

	$params = @{
		Path  = 'LICENSE'
		Value = $licenseText
	}
	Set-Content @params -NoNewline

	$response | Select-Object name, description, implementation | Format-List

	if ($Commit) {
		git add $params.Path
		git commit -m 'New LICENSE'
	}
}
