function Grant-Administrator {
	$ps = switch ($PSVersionTable.PSVersion.Major) {
		{ $_ -le 5 } { 'powershell' }
		{ $_ -ge 6 } { 'pwsh' }
	}
	saps $ps -ArgumentList '-ExecutionPolicy', (Get-ExecutionPolicy) -Verb RunAs
}

function Test-Administrator {
	$currentUser = New-Object System.Security.Principal.WindowsPrincipal (
		[System.Security.Principal.WindowsIdentity]::GetCurrent()
	)
	$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}
