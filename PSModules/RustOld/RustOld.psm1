function Get-RustVersionInfo([switch]$All) {
	$info = [ordered]@{}
	rustc --version --verbose | Select-String ': ' | Sort-Object | % {
		$key, $value = ($_ -split ': ').Trim()
		$info.Add($key, $value)
	}

	if ($All) {
		[pscustomobject]$info
	} else {
		$info.release
	}
}

function Get-RustupComponent {
	param (
		[string[]]
		$Pattern,

		[switch]
		$Installed
	)

	$result = if ($Installed) {
		rustup component list --installed
	} else {
		rustup component list
	}

	if ($Pattern) {
		$result = $result -match ($Pattern -join '|')
	}

	$result
}

function Get-RustupTarget {
	param (
		[string[]]
		$Pattern,

		[switch]
		$Installed
	)

	$result = if ($Installed) {
		rustup target list --installed
	} else {
		rustup target list
	}

	if ($Pattern) {
		$result = $result -match ($Pattern -join '|')
	}

	$result
}
