#Requires -Modules Core

function Backup-VscodeUserSettingsJson {
	Backup-Item $VSCODE_USER_SETTINGS_JSON
}

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

function New-VscodeWorkspaceSettingsJson {
	param (
		[switch]
		$Commit
	)

	New-Item .vscode -ItemType Directory -ErrorAction Stop
	Set-Content -Path .vscode/settings.json -Value @'
{
	"editor.detectIndentation": false,
	"editor.insertSpaces": false,
	"files.associations": {
		"*.ps1xml": "xml"
	},
	"files.insertFinalNewline": true,
	"files.trimTrailingWhitespace": true,

	"omnisharp.enableEditorConfigSupport": true,
	"omnisharp.enableRoslynAnalyzers": true,
	"omnisharp.organizeImportsOnFormat": true,

	"powershell.codeFormatting.newLineAfterCloseBrace": false,
	"powershell.codeFormatting.openBraceOnSameLine": true,
	"powershell.codeFormatting.useConstantStrings": true,
	"powershell.codeFormatting.useCorrectCasing": true,
	"powershell.codeFormatting.whitespaceBetweenParameters": true,
}
'@

	if ($Commit) {
		git add .vscode/settings.json
		git commit -m 'New VS Code settings'
	} else {
		Write-Host @'
Command for commit:
git add .vscode/settings.json
git commit -m 'New VS Code settings'
'@ -ForegroundColor Green
	}
}
