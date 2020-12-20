function Get-EnvironmentVariable {
	[alias('Get-Env')]
	param (
		[string[]]
		$Name,

		[string[]]
		$Value,

		[System.EnvironmentVariableTarget]
		$Target = [System.EnvironmentVariableTarget]::Process
	)

	$all = [System.Environment]::GetEnvironmentVariables($Target)

	$result = if (!$Name -and !$Value) { $all.GetEnumerator() }
	foreach ($n in $Name) {
		$result += $all.GetEnumerator() | Where-Object Key -Like $n
	}
	foreach ($v in $Value) {
		$result += $all.GetEnumerator() | Where-Object Value -Like $v
	}

	$result | Sort-Object Key -Unique
}

function Set-EnvironmentVariable {
	[alias('Set-Env')]
	param (
		[Parameter(Mandatory)]
		[string]
		$Name,

		[string]
		$Value,

		[System.EnvironmentVariableTarget]
		$Target = [System.EnvironmentVariableTarget]::Process
	)

	[System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
}

. (Join-Path $PSScriptRoot PATH.ps1)
. (Join-Path $PSScriptRoot HttpProxy.ps1)
