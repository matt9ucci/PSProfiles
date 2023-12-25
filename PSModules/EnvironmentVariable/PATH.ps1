function Get-PathEnvironmentVariable {
	[alias('Get-PathEnv')]
	param (
		[System.EnvironmentVariableTarget]
		$Target = [System.EnvironmentVariableTarget]::Process
	)

	[System.Environment]::GetEnvironmentVariable('PATH', $Target) -split [System.IO.Path]::PathSeparator
}

function Set-PathEnv {
	param (
		[string[]]$Path,
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process
	)

	Set-Env 'PATH' ($Path -join [System.IO.Path]::PathSeparator) $Target
}

function Add-PathEnvironmentVariable {
	[alias('Add-PathEnv')]
	param (
		[string]
		$Value,

		[System.EnvironmentVariableTarget]
		$Target = 'Process',

		[switch]
		$First
	)

	if ((Get-PathEnv $Target) -contains $Value) {
		Write-Host $Target "PATH contains" $Value -ForegroundColor Green
	} elseif ($First) {
		Set-PathEnv ((@(, $Value) + (Get-PathEnv $Target)) -join [System.IO.Path]::PathSeparator) $Target
	} else {
		Set-PathEnv (((Get-PathEnv $Target) + $Value) -join [System.IO.Path]::PathSeparator) $Target
	}
}

function Remove-PathEnvironmentVariable {
	[alias('Remove-PathEnv')]
	param (
		[string]
		$Value,

		[System.EnvironmentVariableTarget]
		$Target = [System.EnvironmentVariableTarget]::Process
	)

	if ((Get-PathEnv $Target) -contains $Value) {
		Set-PathEnv ((Get-PathEnv $Target) -ne $Value) $Target
	} else {
		Write-Host $Target "PATH does not contain" $Value -ForegroundColor Green
	}
}
