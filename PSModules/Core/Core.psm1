. $PSScriptRoot\Administrator.ps1
. $PSScriptRoot\Command.ps1
. $PSScriptRoot\Directory.ps1

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

function Export-HttpProxyCredential([string]$Path = "$HOME\.psprofiles\HttpProxyCredential.xml") {
	Get-Credential | Export-Clixml $Path
}
