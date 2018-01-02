function Grant-Administrator {
	$ps = switch ($PSVersionTable.PSVersion.Major) {
		{ $_ -le 5 } { 'powershell' }
		{ $_ -ge 6 } { 'pwsh' }
	}
	saps $ps -ArgumentList "-ExecutionPolicy $(Get-ExecutionPolicy)" -Verb RunAs
}

function New-Directory([string[]]$Path) { New-Item $Path -Force -ItemType Directory }
Set-Alias nd New-Directory

function Edit-Hosts { saps notepad $env:SystemRoot\System32\drivers\etc\hosts -Verb RunAs }
function Test-Administrator { ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) }
