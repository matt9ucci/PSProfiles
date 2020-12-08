switch ($env:OS) {
	'Windows_NT' {
		Set-Variable VSCODE_HOME "$HOME/Apps/VSCode" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_USER_DIR "$env:APPDATA\Code\User" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_EXTENSION_DIR "$HOME\.vscode\extensions" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_USER_SETTINGS_JSON "$VSCODE_USER_DIR\settings.json" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_USER_KEYBINDINGS_JSON "$VSCODE_USER_DIR\keybindings.json" -Option ReadOnly, AllScope -Scope Global -Force
		Set-Variable VSCODE_ZIP_URL https://go.microsoft.com/fwlink/?Linkid=850641 -Option ReadOnly, AllScope -Scope Global -Force
	}
	# Mac $HOME/Library/Application Support/Code/User/settings.json
	# Linux $HOME/.config/Code/User/settings.json
	# See https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations
}

function Save-VSCodeBinary([string]$Path = "$DOWNLOADS\vscode.zip") {
	if (Test-Path $Path) {
		Write-Warning "$Path already exists"
	} else {
		Invoke-WebRequest -Uri $VSCODE_ZIP_URL -OutFile $Path -Verbose
		$Path
	}
}

function Install-VSCode([string]$Zip) {
	if (!$Zip) {
		$Zip = Save-VSCodeBinary
	}

	if (Test-Path $VSCODE_HOME) {
		Rename-Item $VSCODE_HOME "$(Split-Path $VSCODE_HOME -Leaf)-$(Get-Date -Format yyMMddHHmmss)"
	}

	Expand-Archive -Path $Zip -DestinationPath $VSCODE_HOME

	& "$PROFILEDIR\PSScripts\New-Desktop.ini.ps1" $VSCODE_HOME -IconFile 'Code.exe'
}
