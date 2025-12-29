using namespace System.Security.Principal

function Grant-Administrator {
	$ps = switch ($PSVersionTable.PSVersion.Major) {
		{ $_ -le 5 } { 'powershell' }
		{ $_ -ge 6 } { 'pwsh' }
	}
	saps $ps -ArgumentList '-ExecutionPolicy', (Get-ExecutionPolicy) -Verb RunAs
}

function Test-Administrator {
	$currentUser = New-Object System.Security.Principal.WindowsPrincipal (
		[WindowsIdentity]::GetCurrent()
	)
	$currentUser.IsInRole([WindowsBuiltInRole]::Administrator)
}
