function Update-VscodeUserSettingsJson {
	$settings = if (Test-Path $VSCODE_USER_SETTINGS_JSON) {
		Get-Content $VSCODE_USER_SETTINGS_JSON | ConvertFrom-Json -AsHashtable -Depth 10
	} else {
		@{}
	}

	$src = Get-Content $PSScriptRoot\settings.json | ConvertFrom-Json -AsHashtable -Depth 10
	$src.Keys | % {
		$settings[$_] = $src[$_]
	}

	$result = [ordered]@{}
	$settings.GetEnumerator() | Sort-Object Name | % {
		$result[$_.Key] = $_.Value
	}
	$result | ConvertTo-Json -Depth 10 | Out-File $VSCODE_USER_SETTINGS_JSON
}
