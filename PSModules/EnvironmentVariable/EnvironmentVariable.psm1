function Get-Env {
	Param(
		[string[]]$Name = '*',
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process
	)

	foreach ($n in $Name) {
		[System.Environment]::GetEnvironmentVariables($Target).GetEnumerator() | Where-Object Key -Like $n
	}
}

function Set-Env {
	Param(
		[Parameter(Mandatory = $true)]
		[string[]]$Name,
		[string]$Value,
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process
	)

	foreach ($n in $Name) {
		[System.Environment]::SetEnvironmentVariable($n, $Value, $Target)
	}
}

. (Join-Path $PSScriptRoot PATH.ps1)
. (Join-Path $PSScriptRoot HttpProxy.ps1)
