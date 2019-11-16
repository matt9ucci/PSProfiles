. $PSScriptRoot\Administrator.ps1
. $PSScriptRoot\Command.ps1
. $PSScriptRoot\Directory.ps1

function Get-Accelerator([string]$Name = '*') {
	$accelerators = [powershell].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
	$accelerators.GetEnumerator() | Where-Object Key -Like $Name | Sort-Object -Property Key
}

function Edit-Hosts { saps notepad $env:SystemRoot\System32\drivers\etc\hosts -Verb RunAs }

function Export-HttpProxyCredential([string]$Path = "$HOME\.psprofiles\HttpProxyCredential.xml") {
	Get-Credential | Export-Clixml $Path
}
