function Get-PathEnv {
	Param(
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process
	)

	(Get-Env 'PATH' $Target).Value -split ';'
}

function Set-PathEnv {
	Param(
		[string[]]$Path,
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process
	)

	Set-Env 'PATH' ($Path -join ';') $Target
}

function Add-PathEnv {
	Param(
		[string]$Path,
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process
	)

	if ((Get-PathEnv $Target) -contains $Path) {
		Write-Host $Target "PATH contains" $Path -ForegroundColor Green
	} else {
		Set-PathEnv ((Get-PathEnv $Target) + $Path) $Target
	}
}

function Remove-PathEnv {
	Param(
		[string]$Path,
		[System.EnvironmentVariableTarget]$Target = [System.EnvironmentVariableTarget]::Process
	)

	if ((Get-PathEnv $Target) -contains $Path) {
		Set-PathEnv ((Get-PathEnv $Target) -ne @($Path)) $Target
	} else {
		Write-Host $Target "PATH does not contain" $Path -ForegroundColor Green
	}
}
